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
  'clc.foundation.data/app/models/monitoring/signal-values-last-model',
  'clc.foundation.data/app/models/configuration/equipments-model',
  'clc.foundation.data/app/models/configuration/stations-model',
  '../../../index-setting.json',
  'moment',
  'underscore'
], (base, event,signal,signallast,equipment,station,setting,moment, _) ->
  class AutoFileService extends base.MqttService
    constructor: (@options) ->
      super @options
      @event = new event.EventValuesModel
      @equip = new equipment.EquipmentsModel
      @station = new station.StationsModel
      @signal = new signal.SignalValuesModel
      @signalLast = new signallast.SignalValuesLastModel
      @fs = require("fs")
      @path = require('path')
      #      @csv = require('fast-csv')
      @request = require('request')
      @equipSignalSubscribe = {}

    initialize: (callback) ->
      super callback
      @writeFile()

    writeFile: ()=>
      @equip.query {user:setting.myproject.user,project:setting.myproject.project},null,(err,equips)=>
        equips = _.filter equips,(item)=> item.group is 'enable'
        @enableEquips = equips
        for equip in equips
          @autoPullData(equip)

    autoPullData: (equip)=>
      #按设备 从服务器下载最新数据到本地         先订阅设备的7个流数据地址和opc数据地址 订阅到了就下载下来
#      console.log equip
      topicKey = "signal-values/" + equip.user + "/" + equip.project + "/" + equip.station + "/" + equip.equipment + "/"
      resources1 = ["s-data-1","s-data-2","s-data-3","s-data-4","s-data-opc"]
      resources2 = ["s-data-5","s-data-6","s-data-7"]
#      resources = _.map resources1,(item)=> return topicKey + item
#      resources3 = _.map resources2,(item)=> return topicKey + item
      # 每整点50分从服务器signalv
      for sig in resources1
        @querySignalValueLast(equip,sig)
      for sig in resources2
        @querySignalValuesLast2(equip,sig)


      #监听信号 订阅到了就下载更新本地
    querySignalValueLast: (equip,sigId)=>
#      console.log topic
      @signalLast.query {user:setting.myproject.user,project:setting.myproject.project,station:equip.station,equipment:equip.equipment,signal:sigId},null,(err,signals)=>
        signal = signals[0]
        fileName = signal.station + "_" + signal.equipment + "_"+ signal.signal + "_" + moment().format('YYYY-MM-DD-HH-mm-ss')
        url = signal.value
        @downLoadCsv(fileName,url)

    querySignalValuesLast2: (equip,sigId)=>
      @signalLast.query {user:setting.myproject.user,project:setting.myproject.project,station:equip.station,equipment:equip.equipment,signal:sigId},null,(err,signals)=>
        signal = signals[0]
        urls = signal.value.split(",")
        index = 0
        for url in urls
          index++
          fileName = signal.station + "_" + signal.equipment + "_" + signal.signal + "_"+ index + "_" + moment().format('YYYY-MM-DD-HH-mm-ss')
          @downLoadCsv(fileName,url)

    downLoadCsv: (filename,url)=>
      console.log '要下载的文件地址为：' + url
      #把usrl的csv文件 下载到fileName的本地路径下
      @request(url)
        .pipe(@fs.createWriteStream(@path.join('/predict',filename)))




  exports =
    AutoFileService: AutoFileService
