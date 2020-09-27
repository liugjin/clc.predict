# File: calculation-service
# User: david
# Date: 2017/3/24
# Desc:

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define [
  'clc.foundation',
  'clc.foundation.data/app/models/monitoring/event-values-model',
  'clc.foundation.data/app/models/monitoring/signal-values-model',
  'clc.foundation.data/app/models/configuration/equipments-model',
  'clc.foundation.data/app/models/configuration/stations-model',
  '../../../index-setting.json',
  'moment',
  'underscore'
], (base, event,signal,equipment,station,setting,moment, _) ->
  class AutoDownloadService extends base.MqttService
    constructor: (@options) ->
      super @options
      @event = new event.EventValuesModel
      @equip = new equipment.EquipmentsModel
      @station = new station.StationsModel
      @signal = new signal.SignalValuesModel
      @fs = require("fs")
      @path = require('path')
#      @csv = require('fast-csv')
      @request = require('request')
      @jobopc = {}
      @jobstream = {}

    initialize: (callback) ->
      super callback
      @writeCsv()



    writeCsv: ()=>
      @equip.query {user:setting.myproject.user,project:setting.myproject.project},null,(err,equips)=>
        equips = _.filter equips,(item)=> item.group is 'enable'
        @enableEquips = equips
        for equip in equips
          @jobopc[equip.equipment] = null
          @jobstream[equip.equipment] = null
          @downopcPerHour(equip)
          @downstreamPerHour(equip)

    downstreamPerHour: (equip)=>
      # 每小时整点发控制采集流数据， 采集到了之后发控制给2000把数据更新到服务器。 更新完成后发完成标记
      pickChannels = ['set-schedule-1','set-schedule-2','set-schedule-3','set-schedule-4','set-schedule-5','set-schedule-6','set-schedule-7']
      queueChannels = ['queue-1-sample','queue-2-sample','queue-3-sample','queue-4-sample','queue-5-sample','queue-6-sample','queue-7-sample']
      sustream = su = (_.find equip.sampleUnits,(i)=> i.id is 'sustream').value
      schedule = require 'node-schedule'
      rulestream = new schedule.RecurrenceRule()
      console.log '--每整点执行采数据控制--' + equip.equipment
      rulestream.minute = 0
      @jobstream[equip.equipment] = schedule.scheduleJob rulestream,()=>
        # 发7个采集的控制指令
        for item in pickChannels
          @getStreamData(equip,item)
        setTimeout ()=>              # 采集完流数据后30s后再发控制让更新到到服务器
          for item in queueChannels
            @getStreamData(equip,item)
        ,60000


    getStreamData: (equip,controlId)=>
      topic1 = "command-values/"+equip.user+"/"+equip.project+"/"+equip.station+"/"+equip.equipment+ "/" + controlId
      console.log topic1
      @publishToMqtt topic1, {user:equip.user, project:equip.project, station:equip.station, equipment:equip.equipment, command: controlId,parameters:[{key:"value",value:1}], phase:'executing',startTime:new Date(),endTime:'',result:'',trigger:'user',operator:setting.myproject.user,operatorName:''}

    downopcPerHour: (equip)=>
      # 取每整点第一分钟的数据
      schedule = require 'node-schedule'
      ruleopc = new schedule.RecurrenceRule()
      ruleopc.minute = 1
      console.log '--每整点零一分执行更新opc数据操作--' + equip.equipment
      @jobopc[equip.equipment] = schedule.scheduleJob ruleopc,()=>
        @getOneEquipInfo equip,(d)=>
          console.log '---回调处理--'
#          console.log d
          fileName = equip.station + "_" + equip.equipment + "_" + moment().format('YYYY-MM-DD-HH-mm-ss') + '.csv'
          createCsvWriter = require('csv-writer').createObjectCsvWriter;
          csvWriter = createCsvWriter({
            path: fileName,
            header: d.header
            })
          data = d.data
          csvWriter
            .writeRecords(data)
            .then(()=>
              console.log  fileName + "-- was written successfully, 然后用request库把文件传到服务器指定地址"
              setTimeout ()=>  # 60秒后再往服务器resource里传文件
                csvpath = fileName
                urlstr = "http://#{setting.host}/resource/upload/predict/input/21012B1100293/#{fileName}?author=#{setting.author}&project=#{setting.myproject.project}&token=#{setting.token}"
#                console.log urlstr
                @request.post {
                  url: urlstr
                  json: true
                  headers: {
                    "content-type": "application/json",
                  }
                  formData:
                    file: @fs.createReadStream csvpath
                }, (err, response, body) =>
                  if !err && response.statusCode == 200
#                    console.log body
                    pubName = "http://#{setting.host}/resource/upload/" + body.path
                    console.log "文件上传成功 要发布的topic为" + d.su + "主题message地址为：" + pubName
                    @fs.unlinkSync(fileName)
                    if d.su
                      @publishData d.su,pubName
              ,60000
            );


    getOneEquipInfo:(equip,callback)=>
      su = (_.find equip.sampleUnits,(i)=> i.id is 'su').value
#        console.log '-------查询设备信息------'
#        console.log equip
      equipproperties = {}
      for item in equip.properties
        equipproperties[item.id] = item.value

      _opcsignals = _.pluck(JSON.parse(equipproperties['_opcsignals']),'signal')
#        console.log _opcsignals
      # 遍历_opcsignals的信号id数组 分别查询数据库数据
      headers= []
      allDatas = []
      cbdata = {}
      index = 0
      startTime =  moment().startOf('hour')
      endTime =  moment().startOf('hour').add(1, 'minute')
      for item in _opcsignals
#          console.log item
        @signal.query {user:setting.myproject.user,project:setting.myproject.project,station:equip.station,equipment:equip.equipment,signal:item,timestamp:{"$gte":startTime,"$lt":endTime}},null,(err,signals)=>
          console.log err if err
          if signals.length
            console.log '-------'+signals[0].equipment+"----"+signals[0].signal+'-------'
          else
            return console.log "此信号无数据记录" if not signals or (signals.length == 0)
          index++
          id = equip.station + "_" + equip.equipment + "_" + signals[0].signal
          headers.push {id:id,title:id}
#            console.log signals
          signalRecords = _.sortBy signals,'timestamp'
#          signalRecords.reverse()
          finalData = _.pluck signalRecords,'value'
#          console.log finalData
          datas = []
          for d in finalData
            data = {}
            data[id] = d
            datas.push data
          if allDatas.length is 0
            allDatas = JSON.parse(JSON.stringify(datas))
          else
            assign = (target, args) ->
              if target == null
                return
              if Object.assign
                Object.assign target, args
              else
                _ = Object(target)
                j = 1
                while j < arguments.length
                  source = arguments[j]
                  if source
                    for key of source
                      if Object::hasOwnProperty.call(source, key)
                        _[key] = source[key]
                  j++
                _

            allDatas = allDatas.map((o,index)->
                assign o,datas[index]
            )


          if index == _opcsignals.length
            cbdata = {header:headers,data:allDatas,su:su}
            callback? cbdata


    publishData: (su,url) =>
      if su
        topic0 = "ssv/"+su+"/s-data-opc"
        console.log "发布opc数据topic为:"+ topic0 + "--消息内容为:" + url
        @publishToMqtt topic0, url, {qos:0, retain: true}




  exports =
    AutoDownloadService: AutoDownloadService
