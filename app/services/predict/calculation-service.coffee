# File: calculation-service
# User: david
# Date: 2017/3/24
# Desc:

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define [
  'clc.foundation',
  'clc.foundation.data/app/models/monitoring/event-values-model',
  'clc.foundation.data/app/models/configuration/equipments-model',
  'clc.foundation.data/app/models/configuration/stations-model',
  'underscore'
], (base, event,equipment,station, _) ->
  class CalculationService extends base.MqttService
    constructor: (@options) ->
      super @options
      @event = new event.EventValuesModel
      @equip = new equipment.EquipmentsModel
      @station = new station.StationsModel
      @map = {}
      @stationMap = {}
      @stations = {}

    initialize: (callback) ->
      super callback
      @firstload()

      @subscribeToMqtt 'configuration/equipment/#', {qos:1}, (data) =>
        @map = {}
        @stationMap = {}
        @stations = {}
        @firstload()
      ,false
      @subscribeToMqtt 'configuration/station/#', {qos:1}, (data) =>
        @map = {}
        @stationMap = {}
        @stations = {}
        @firstload()
      ,false

    firstload: () ->
      @event.aggregate [
        {$match:{endTime:{$eq: null}, forceToEnd:{$ne:true}}},
        {$group:{_id:{user:"$user",project:"$project",station:"$station",equipment:"$equipment"},alarmNum:{$sum:1},alarmSeverity:{$max:"$severity"},alarmLevelList:{$push:"$severity"},alarmList:{$push:{event:"$event", startTime:"$startTime"}}}},
        {$project:{_id:0, user: "$_id.user", project:"$_id.project",station:"$_id.station",equipment:"$_id.equipment",alarmNum:"$alarmNum",alarmSeverity:"$alarmSeverity",alarmLevelList:"$alarmLevelList",alarmList:"$alarmList"}}
      ], null, (err,data) =>
        if err
          console.log err
          data = []
        @station.query {}, null, (err, stations) =>
          if !err
            for station in stations
              id = station.user+"."+station.project+"."+station.station
              @stationMap[id] = {user:station.user, project:station.project, station:station.parent} if station.parent

          @equip.query {}, null,(err, equips) =>
            if !err
              _.each equips, (equip)=>
                if equip.equipment is "_station_management"
                  id = equip.user+"."+equip.project+"."+equip.station
                  @stations[id] = {su:equip.sampleUnits?[0]?.value, equipNum: 0, alarmNum: 0, alarmSeverity:0, alarmLevelList:[]}
              @publishdata @stations

              for equip in equips
                if equip.equipment?.indexOf("_") != 0
                  id = equip.user+"."+equip.project+"."+equip.station
                  @stationMap[id]?.equipNum += 1
                  equipid = equip.user+"."+equip.project+"."+equip.station+"."+equip.equipment
                  suid = equip.sampleUnits?[0]?.value
                  eq = _.findWhere(data, {user:equip.user, project:equip.project,station:equip.station,equipment:equip.equipment})
                  if eq
                    @map[equipid] = eq
                  else
                    @map[equipid] = {user:equip.user, project:equip.project,station:equip.station,equipment:equip.equipment,alarmNum:0,alarmSeverity:0, alarmLevelList:[], alarmList:[]}
                  @map[equipid].fullequipment = equipid
                  @map[equipid].su = suid
                  @map[equipid].num = if equip.type is "loop" then 0 else 1

                  @computestation @map[equipid]

            @publishdata @map

            @subscriber?.dispose()
            @subscriber = @subscribeToMqtt 'event-values/#',{qos:0}, (data) =>
              @calculate data
            ,false
            @subscriber2?.dispose()
            @subscriber2 = @subscribeToMqtt 'event-process/#',{qos:0}, (data) =>
              @calculate data
            ,false

    calculate: (data)->
      msg = data.message
      id = msg.user+"."+msg.project+"."+msg.station+"."+msg.equipment
      alarmSeverity = msg.severity
      if @map[id]
#        console.log "begin to calculate"
        alarms = @map[id].alarmList
        flag = _.find alarms, (item)->item.event is msg.event and item.startTime.toISOString() is msg.startTime
        return if (not flag and msg.phase in ["end", "completed"]) or (flag and msg.phase is "start")
        list = @map[id].alarmLevelList
        if msg.phase is "start"
          @map[id].alarmNum++
          list.push alarmSeverity
          alarms.push {event: msg.event, startTime: new Date(msg.startTime)}
        else if msg.phase is "end" or msg.phase is "completed"
          @map[id].alarmNum--
          for level, i in list
            if level == alarmSeverity
              list.splice(i, 1)
              break
          j = alarms.indexOf(flag)
          alarms.splice(j, 1)
        if list.length
          @map[id].alarmSeverity = _.max(list)
        else
          @map[id].alarmSeverity = 0
        @publishdata {id : @map[id]}

        @computestation @map[id]
        @publishstationdata msg

    computestation: (device)->
      stationid = device.user+"."+device.project+"."+device.station
      if !@map[stationid]
        suid = @stations[stationid]?.su
        @map[stationid] = {user:device.user, project:device.project,station:device.station,equipment:"_station_management",fullequipment:stationid+"._station_management",deviceList:{}, su:suid}
      @map[stationid].deviceList[device.fullequipment] ={alarmNum:device.alarmNum,alarmSeverity:device.alarmSeverity,alarmLevelList:device.alarmLevelList, equipNum:device.num ? device.equipNum}
      deviceList = _.values(@map[stationid].deviceList)
      @map[stationid].alarmNum = _.reduce deviceList, (memo,device)->
        return memo+device.alarmNum
      , 0
      @map[stationid].equipNum = _.reduce deviceList, (memo,device)->
        return memo+device.equipNum
      , 0
      @map[stationid].alarmSeverity = _.max(_.pluck(deviceList,"alarmSeverity"))
      list = []
      _.each deviceList, (device) ->
        list = list.concat device.alarmLevelList
      @map[stationid].alarmLevelList = list

      if @stationMap.hasOwnProperty stationid
        parentStation = JSON.parse JSON.stringify @map[stationid]
        parentStation.station = @stationMap[stationid].station
        @computestation parentStation

    publishstationdata: (station) =>
      stationid = station.user+"."+station.project+"."+station.station
      @publishdata {id: @map[stationid]}
      if @stationMap.hasOwnProperty stationid
        @publishstationdata @stationMap[stationid]

    publishdata: (data) =>
#      console.log data
      for k,d of data
        if d.su
          topic0 = "ssv/"+d.su+"/alarms"
          @publishToMqtt topic0, d.alarmNum, {qos:0, retain: true}
          topic2 = "ssv/"+d.su+"/alarmSeverity"
          @publishToMqtt topic2, d.alarmSeverity, {qos:0, retain: true}
          topic3 = "ssv/"+d.su+"/alarmSeverityMap"
          alarmSeverityMap = _.countBy d.alarmLevelList
          @publishToMqtt topic3, alarmSeverityMap, {qos:0, retain: true}
        if d.su and not isNaN d.equipNum
          topic = "ssv/"+d.su+"/equipments"
          @publishToMqtt topic, d.equipNum, {qos:0, retain: true}

  exports =
    CalculationService: CalculationService
