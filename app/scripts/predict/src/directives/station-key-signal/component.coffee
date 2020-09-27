###
* File: station-key-signal-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationKeySignalDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-key-signal"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      scope.defaultColor = '#F4F7FF'
      @getDeviceOrSignals(scope)
      scope.stationEventBus?.dispose()
      scope.stationEventBus = @commonService.subscribeEventBus 'stationID',(msg)=>
        stationID = msg.message.data
        @commonService.loadStation stationID, (err,station) =>
          scope.station = station
          @getDeviceOrSignals(scope)
    # 获取设备对象和对应的信号列表
    getDeviceOrSignals:(scope)=>
      scope.signalDataArr = []
      scope.equipSubscription = {}
      @commonService.loadEquipmentById scope.station, '_station_management', (err,equipment) =>
        if(equipment)
          equipment.loadSignals null,(err,signals)=>
            for sig in signals
              # 过滤对应设备模板里面的信号
              if(sig.model.template == "_station_management_template")
                # 设置页面展示的数据格式
                signalData = {equipName:'',signalName:'',setValue:0,unit:'',signalID:'',severity:'',severityColor:'',severityLabelColor:''}
                signalData.equipName = equipment.model.name
                signalData.signalName = sig.model.name
                signalData.unit = sig.model.desc
                signalData.signalID = sig.model.signal
                scope.signalDataArr.push(signalData)
                @getDeviceSpecialSignal(scope,sig)
    # 订阅信号
    getDeviceSpecialSignal:(scope,sig)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
        equipment: sig.equipment.model.equipment
        signal: sig.model.signal
      scope.equipSubscription[sig.model.signal]?.dispose()
      scope.equipSubscription[sig.model.signal] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
        if signal and signal.message
          sig?.setValue signal.message
#          console.log 'sig',sig
          for data in scope.signalDataArr
            if(data.signalID == signal.message.signal)
              data.setValue = sig.data.formatValue
              data.serverity = sig.data.severity
              data.severityColor = @getSeverityColor(scope,sig.data.severity)
              data.severityLabelColor = @getSeverityLabelColor(scope,sig.data.severity)

    getSeverityColor: (scope,severity)=>
      return scope.defaultColor if severity<1
#      dictionary = scope.project.typeModels.eventseverities.keys
#      color = dictionary[severity.toString()].model.color
      # 按设计稿给信号值和边框颜色，如果该信号有告警 #FADB00
      color = '#FADB00'
      return color
    getSeverityLabelColor: (scope,severity)=>
      return scope.defaultColor if severity<1
      # 按设计稿给信号名称的颜色 ，如果该信号有告警 #FADB00
      color = '#F4D601'
      return color

    resize: (scope)->

    dispose: (scope)->
#      scope.stationEventBus?.dispose()
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    StationKeySignalDirective: StationKeySignalDirective