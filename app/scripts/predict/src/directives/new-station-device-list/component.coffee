###
* File: new-station-device-list-directive
* User: David
* Date: 2019/12/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class NewStationDeviceListDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "new-station-device-list"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.motor = [] #电机设备
      scope.inverter = [] #变频器
      scope.transformer = [] #变压器
      scope.switchBox = []  #开关柜
      scope.allMotorNumber = 0 #投放电机数量
      scope.allInverterNumber = 0 #投放的变频器数量
      scope.allConverterNumber = 0 #投放的变压器数量
      scope.allSwitchBoxNumber = 0  #投放的开关柜数量
      scope.equipSubscription = {}
      scope.motorState = {runningNumber:'00',offlineNumber:'00',alarmNumber:'00',forecastNumber:'00'} #电机状态数据
      scope.inverterState = {runningNumber:'00',offlineNumber:'00',alarmNumber:'00',forecastNumber:'00'} #变频器状态数据
      scope.transformerState = {runningNumber:'00',offlineNumber:'00',alarmNumber:'00',forecastNumber:'00'} #变压器状态数据
      scope.switchBoxState = {runningNumber:'00',offlineNumber:'00',alarmNumber:'00',forecastNumber:'00'} #开关柜状态数据
      scope.motorArr = {runningNumber:[],offlineNumber:[],alarmNumber:[],forecastNumber:[]}#电机状态设备数组
      scope.inverterArr = {runningNumber:[],offlineNumber:[],alarmNumber:[],forecastNumber:[]}#变频器状态设备数组
      scope.transformerArr = {runningNumber:[],offlineNumber:[],alarmNumber:[],forecastNumber:[]}#变压器状态设备数组
      scope.switchBoxArr = {runningNumber:[],offlineNumber:[],alarmNumber:[],forecastNumber:[]}#开关柜状态设备数组
      scope.equipTypeLists = {}
#      scope.devicesStatusNum =

      scope.equipNumData =
        runningNumber: '00'
        offlineNumber: '00'
        alarmNumber: '00'
        forecastNumber: '00'
      #      scope.loadEqipDetails = ()=>
      if scope.showDeviceData
        scope.equipDetailUrl = '#/device-details/'+scope.project.model.user+'/'+scope.project.model.project+'?station='+scope.station.model.station+'&equipment='+scope.showDeviceData.model.equipment
      # 窗口切换
      scope.focus = 1
      scope.clickTime=(i)=>
        scope.focus = i
        @getOneDevice(scope)
      scope.clickDevice=(data)=>
        @clickDevice(scope,data)

      if scope.station && scope.station.model.group == 'datacenter'
         scope.station = scope.project.stations.items[1]
      @getDevice(scope)

      scope.stationSubscription?.dispose()
      scope.stationSubscription = @commonService.subscribeEventBus "selectStation", (msg) =>
        scope.equipments = []
        station = _.find scope.project.stations.items, (sta)->sta.model.station is msg.message.id
        @selectStation scope, station

    selectStation: (scope, station) ->
      scope.station = station
      scope.equipTypeLists = _.map scope.categories[station.model.station], (value, key)->
        item = _.find scope.project.dictionary.equipmenttypes.items, (it)->it.model.type is key
        if item
          value.image = item.model.image
          value.index = item.model.index
        value
      scope.equipTypeLists = _.sortBy scope.equipTypeLists, (item)->0-item.index
      @getDevice(scope)
    getDevice:(scope)=>
#      scope.station = scope.station.stations[0]
      scope.station.loadEquipments null, null, (err, equipments)=>
        if equipments
          for eq in equipments
            eq.model.newCreatetime = eq.model.createtime.split("T")[0]
            if eq.model.properties.length > 0
              for item in eq.model.properties
                if item.id == 'production-time'
                  eq.model.productionTime = item.value
                  eq.model.productionTime = eq.model.productionTime.split("T")[0]
            if eq.model.type == 'motor'
              scope.motor.push eq
            else if eq.model.type == 'inverter'
              scope.inverter.push eq
            else if eq.model.type == 'transformer'
              scope.transformer.push eq
            else if eq.model.type == 'switch-box'
              scope.switchBox.push eq
          if scope.switchBox.length >0
            scope.switchBox.reverse()
          scope.allMotorNumber =@addZero(scope.motor.length)
          scope.allInverterNumber =@addZero(scope.inverter.length)
          scope.allConverterNumber = @addZero(scope.transformer.length)
          scope.allSwitchBoxNumber = @addZero(scope.switchBox.length)
          @getOneDevice(scope)
          @getDeviceSignal(scope,scope.station,scope.motor,'communication-status','runState','motor',scope.motorArr,scope.motorState,'runningNumber','offlineNumber')
          @getDeviceSignal(scope,scope.station,scope.motor,'alarm-status',"alarmState",'motor',scope.motorArr,scope.motorState,'forecastNumber','alarmNumber',)
          @getDeviceSignal(scope,scope.station,scope.inverter,'communication-status','runState','inverter',scope.inverterArr,scope.inverterState,'runningNumber','offlineNumber')
          @getDeviceSignal(scope,scope.station,scope.inverter,'alarm-status','alarmState','inverter',scope.inverterArr,scope.inverterState,'forecastNumber','alarmNumber')
          @getDeviceSignal(scope,scope.station,scope.transformer,'communication-status','runState','transformer',scope.transformerArr,scope.transformerState,'runningNumber','offlineNumber')
          @getDeviceSignal(scope,scope.station,scope.transformer,'alarm-status','alarmState','transformer',scope.transformerArr,scope.transformerState,'forecastNumber','alarmNumber')
          @getDeviceSignal(scope,scope.station,scope.switchBox,'communication-status','runState','switch-box',scope.switchBoxArr,scope.switchBoxState,'runningNumber','offlineNumber')
          @getDeviceSignal(scope,scope.station,scope.switchBox,'alarm-status','alarmState','switch-box',scope.switchBoxArr,scope.switchBoxState,'forecastNumber','alarmNumber')
          # 获取设备信号

          @getDeviceSignal(scope,scope.station,equipments,'device-power','devicePower')
          @getDeviceSignal(scope,scope.station,equipments,'abroad','abroad')
          @getDeviceSignal(scope,scope.station,equipments,'within','within')
          @getDeviceSignal(scope,scope.station,equipments,'electric-current','current')

# 获取设备信号
    getDeviceSignal:(scope,site,equipments,signalID,setValue,template,deviceArr0,deviceState,siteValue0,siteValue1)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: site.model.station
        equipment: '+'
        signal: signalID
      #      if signalID is 'communication-status' and template is 'inverter'
      str = site.key+"-"+signalID+"-"+template
      scope.equipSubscription[str]?.dispose()
      scope.equipSubscription[str] = @commonService.signalLiveSession.subscribeValues filter,(err, d)=>
        if d and d.message
          for equipment in equipments
            if equipment.model.equipment == d.message.equipment
              equipment.model[setValue] = d.message.value

          if !template
            return
          deviceArr0[siteValue0].splice(0, deviceArr0[siteValue0].length)
          deviceArr0[siteValue1].splice(0, deviceArr0[siteValue1].length)

          for equipment in equipments
#            console.log equipment
            if signalID == 'communication-status'
              if equipment.model[setValue] == 0
                deviceArr0[siteValue0].push equipment
              if equipment.model[setValue] == -1
                deviceArr0[siteValue1].push equipment
            else if signalID == 'alarm-status'
              if equipment.model[setValue] == 0
                deviceArr0[siteValue0].push equipment
              if equipment.model[setValue] == 1
                deviceArr0[siteValue1].push equipment

          deviceState[siteValue0] = @addZero(deviceArr0[siteValue0].length)
          deviceState[siteValue1] = @addZero(deviceArr0[siteValue1].length)
          if scope.focus == 1
            scope.equipNumData = scope.motorState


# 获取设备的ocpa平台上的信号
    getOcpaSignals: (scope)=>
      scope.daysRunning = 0
      scope.signalDataArr = []
      scope.switchBoxSignals = []
      @countDays(scope)

      scope.signalDataArr = [
        {stateName:'当前状态',setValue:'--',unit:'',signalID:'communication-status'}
        {stateName:'运行天数',setValue:scope.daysRunning,unit:'天',signalID:''}
      ]
      @getDeviceSpecialSignal(scope,scope.equipment,'communication-status')
      scope.equipTypesId = ["transformer", "inverter","switch-box","motor"]
      scope.equipTemplatesId = ["base-motor","base-cabinet","base-converter","base-transformer"]
      scope.equipment.loadSignals null,(err,signals)=>
        if err
          return
        else
          for sig in signals
            if sig.model.type in scope.equipTypesId
              if sig.model.template  not in scope.equipTemplatesId
                scope.switchBoxSignals.push(sig)
          for j in scope.switchBoxSignals
            console.log j
            scope.signalDataArr.push({stateName:j.model.name,setValue: 0,unit:j.model.desc,signalID:j.model.signal})
            @getDeviceSpecialSignal(scope,scope.equipment,j.model.signal)



#          for item in signals
#            if item.model.group && item.model.group == 'box'
#              scope.switchBoxSignals.push(item)
#          for j in scope.switchBoxSignals
#            scope.signalDataArr.push({stateName:j.model.name,setValue: 0,unit:j.model.definition,signalID:j.model.signal})
#            @getDeviceSpecialSignal(scope,scope.equipment,j.model.signal)
# 封装获取设备信息号函数
    getDeviceSpecialSignal:(scope,equipment,signalID)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: equipment.model.station
        equipment: equipment.model.equipment
        signal: signalID
      str = equipment.key + "-"+ signalID
      scope.equipSubscription[str]?.dispose()

      scope.equipSubscription[str] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
        console.log signal
        if signal and signal.message
          for data in scope.signalDataArr
            if signalID == data.signalID
              if signalID == "communication-status"
                console.log signal
                if signal.message.value == 0
                  data.setValue = '运行'
                else
                  data.setValue = '停机'
              else
                data.setValue = (signal.message.value).toFixed(2)
#   计算设备已使用的天数
    countDays:(scope)=>
      time = Date.parse(new Date())
      lasttime = Date.parse(scope.equipment.model.createtime)
      if scope.equipment.model.properties.length > 0
        for item in scope.equipment.model.properties
          if item.id == 'production-time'
            lasttime = Date.parse(item.value)
      scope.daysRunning = parseInt((time-lasttime)/(1000*60*60*24))
# 点击设备
    clickDevice:(scope,data)=>
      scope.showDeviceData = data
      scope.equipment = data
      if scope.showDeviceData
        scope.equipDetailUrl = '#/device-details/'+scope.project.model.user+'/'+scope.project.model.project+'?station='+scope.station.model.station+'&equipment='+scope.showDeviceData.model.equipment
        @getOcpaSignals(scope)
# 获取第一个设备
    getOneDevice:(scope)=>
      if scope.focus == 1
        scope.showDeviceData = scope.motor[0]
        scope.equipment = scope.motor[0]
        scope.equipNumData = scope.motorState
      if scope.focus == 2
        scope.showDeviceData = scope.inverter[0]
        scope.equipment = scope.inverter[0]
        scope.equipNumData = scope.inverterState
      if scope.focus == 3
        scope.showDeviceData = scope.switchBox[0]
        scope.equipment = scope.switchBox[0]
        scope.equipNumData = scope.switchBoxState
      if scope.focus == 4
        scope.showDeviceData = scope.transformer[0]
        scope.equipment = scope.transformer[0]
        scope.equipNumData = scope.transformerState
      if scope.showDeviceData
        scope.equipDetailUrl = '#/device-details/'+scope.project.model.user+'/'+scope.project.model.project+'?station='+scope.station.model.station+'&equipment='+scope.showDeviceData.model.equipment
        @getOcpaSignals(scope)
    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num
    resize: (scope)->

    dispose: (scope)->
      _.mapObject scope.equipSubscription,(item)=>
        item.dispose()

  exports =
    NewStationDeviceListDirective: NewStationDeviceListDirective