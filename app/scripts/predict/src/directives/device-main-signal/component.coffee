###
* File: device-main-signal-directive
* User: David
* Date: 2020/02/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceMainSignalDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-main-signal"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.showEquipsFlag = false
      console.log(scope.equipment)
      scope.signalDataArr = []
      scope.equipSubscription = {}
      scope.equipmentState = "正常"
      scope.currentOpcSignal = []   #当前opc信号 opc信号弹窗用

      scope.hidemodal = ()->
        $('#opc-modal').modal('close')
        scope.$root.loading = false
      scope.showmodal = ()->
        $('#opc-modal').modal('open')

      scope.checkSignal=(sig)->
        WebuiPopovers.hideAll()
        scope.currentOpcSignal = sig
        scope.chartTitle = sig.equipName + "/" + sig.signalName
        $('#opc-modal').modal('open')
      scope.clickStation = ()=>
        window.location.hash = "#/station-info/#{scope.project.model.user}/#{scope.project.model.project}/#{scope.station.model.station}"

      # 取设备通讯状态信号
      @getDeviceSpecialSignal(scope,"communication-status",null)
      # 获取该设备的所有信号点
      scope.equipment.loadSignals null,(err,signals)=>
        if(signals)
          index=0
          for sig in signals
            if(sig.model.template == scope.equipment.model.template)
              index++
              # 取信号点的前6个
              if(index>6)
#                return console.log("index",index)
              else
                # 设置页面展示的数据格式
                signalData = {equipName:'',signalName:'',setValue:0,unit:'',signalID:'',severity:'',severityColor:'',severityLabelColor:''}
                signalData.equipName = scope.equipment.model.name
                signalData.signalName = sig.model.name
                signalData.unit = sig.model.desc
                signalData.signalID = sig.model.signal
                scope.signalDataArr.push(signalData)
                @getDeviceSpecialSignal(scope,sig.model.signal,sig)
      ,true
     # 订阅主要信号
    getDeviceSpecialSignal:(scope,signalID,sig)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
        equipment: scope.equipment.model.equipment
        signal: signalID
      scope.equipSubscription[signalID]?.dispose()
      scope.equipSubscription[signalID] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
        if signal and signal.message
          sig?.setValue signal.message
          signal = signal.message
          @setDeviceSignal(scope,signalID,signal,sig)
    # 处理订阅回来的信号
    setDeviceSignal:(scope,signalID,signal,sig)=>
      if(signalID == "communication-status" and signal.signal == "communication-status" )
        if(signal.value == -1)
          scope.equipmentState = "离线"
        if(signal.value == 0)
          scope.equipmentState = "正常"
      else
        for data in scope.signalDataArr
          if(data.signalID == signal.signal)
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

    # 小于2位数前面补0
    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num
    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    DeviceMainSignalDirective: DeviceMainSignalDirective