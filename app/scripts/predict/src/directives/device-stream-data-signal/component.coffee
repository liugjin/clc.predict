###
* File: device-stream-data-signal-directive
* User: David
* Date: 2020/02/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceStreamDataSignalDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-stream-data-signal"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      scope.originalDataFlag = true
      scope.streamFlag = false
      scope.currentSignal ={}
      scope.hidemodal = ()->
        $('#stream-chart-modal').modal('close')
        scope.$root.loading = false
        scope.streamFlag = false
      scope.showmodal = ()->
        $('#stream-chart-modal').modal('open')

      scope.checkSignal=()->
#        scope.currentOpcSignal = sig
        $('#stream-chart-modal').modal('open')
      scope.checkStreamSignal = (model)->
        WebuiPopovers.hideAll()
        scope.streamFlag = true
        console.log model
        if scope.currentSignal.name
          if scope.currentSignal.name != model.name
            scope.originalDataFlag = true
        scope.currentSignal.name = model.name
        scope.currentSignal.signal = model.signal
        scope.chartModal = 1
        if model.signal == 's-data-7' || model.signal == 's-data-6' || model.signal == 's-data-5'
          scope.chartModal = 3
        else
          scope.chartModal =1

      scope.streamArr = []
      # 获取该设备的所有信号点
      setTimeout ()=>
        scope.equipment.loadSignals null,(err,signals)=>
          if(signals)
            for sig in signals
              if(sig.model.template == "predict-base-class" and sig.model.group and sig.model.group == "stream")

                sig.model.imgUrl = @getComponentPath('images/'+sig.model.signal+'.svg')
                scope.streamArr.push(sig)
        ,true
      ,10

      scope.switchEventBus?.dispose()
      scope.switchEventBus = @commonService.subscribeEventBus 'old-new-stream-flag',(msg) =>
        if msg.message == 'old'
          scope.originalDataFlag = false
        else if msg.message == 'new'
          scope.originalDataFlag = true
        scope.$applyAsync()

    resize: (scope)->

    dispose: (scope)->


  exports =
    DeviceStreamDataSignalDirective: DeviceStreamDataSignalDirective