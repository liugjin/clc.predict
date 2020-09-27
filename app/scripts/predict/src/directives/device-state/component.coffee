###
* File: device-state-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceStateDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-state"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.equipSubscription = {}
      scope.signalDataArr = []
      scope.showDevice = false
      scope.focus = null
    # 获取该设备的所有信号点
      scope.equipment.loadSignals null,(err,signals)=>
        if(signals)
          for sig in signals
            if(sig.model.type == scope.equipment.model.type)
#              if(sig.model.template == "base-"+scope.equipment.model.type and sig.model.signal !="device-flag")
              if(sig.model.template == "base-"+scope.equipment.model.type and sig.model.signal not in ["device-flag","device-health"])
                signalValue = {stateName:"",stateValue:'优秀',setValue:0,imgUrl:"",signalID:''}
                signalValue.stateName = sig.model.name
                if sig.model.type is 'motor'
                  signalValue.imgUrl =  "#{@getComponentPath('images/'+sig.model.signal+"-1.svg")}"
                else
                  signalValue.imgUrl =  "#{@getComponentPath('images/'+sig.model.type+".svg")}"
                signalValue.signalID = sig.model.signal
                scope.signalDataArr.push(signalValue)
                @getDeviceSpecialSignal(scope,scope.equipment,sig.model.signal)
    #点击信号li选中3D模型零件
      scope.singleSeenter = (i,data)=>
        @commonService.publishEventBus "select",{data:data}
    
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
        if signal and signal.message
          for data in scope.signalDataArr
            if signalID == data.signalID
              data.setValue = signal.message.value
              if(signal.message.value< 25)
                data.stateValue = "优秀"
              if(signal.message.value>=25 and signal.message.value< 50)
                data.stateValue = '良好'
              if(signal.message.value>=50 and signal.message.value< 75)
                data.stateValue = '一般1'
              if(signal.message.value>=75)
                data.stateValue = '极差'
    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    DeviceStateDirective: DeviceStateDirective