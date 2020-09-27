###
* File: device-temperature-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceTemperatureDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-temperature"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.equipSubscription = {}
      scope.daysRunning = 0
      scope.signalDataArr = []
      scope.switchBoxSignals = []
      @countDays(scope)
      if scope.equipment.model.type == 'motor'
        scope.signalDataArr = [
          {stateName:'当前状态',setValue:'运行',unit:'',signalID:'current-state'}
          {stateName:'外部温度',setValue:0,unit:'℃',signalID:'abroad'}
          {stateName:'外壳温度',setValue:0,unit:'℃',signalID:'shell'}
          {stateName:'定子温度',setValue:0,unit:'℃',signalID:'iron-core'}
          {stateName:'输出电流',setValue:0,unit:'A',signalID:'electric-current'}
          {stateName:'运行天数',setValue:scope.daysRunning,unit:'天',signalID:''}
        ]
        @getDeviceSpecialSignal(scope,scope.equipment,'current-state')
        @getDeviceSpecialSignal(scope,scope.equipment,'abroad')
        @getDeviceSpecialSignal(scope,scope.equipment,'shell')
        @getDeviceSpecialSignal(scope,scope.equipment,'iron-core')
        @getDeviceSpecialSignal(scope,scope.equipment,'electric-current')
        @getDeviceSpecialSignal(scope,scope.equipment,'rate')
      else if scope.equipment.model.type == 'inverter'
        scope.signalDataArr = [
          {stateName:'当前状态',setValue:'运行',unit:'',signalID:'current-state'}
          {stateName:'外部温度',setValue:0,unit:'℃',signalID:'abroad'}
          {stateName:'内部温度',setValue:0,unit:'℃',signalID:'within'}
          {stateName:'散热器温度',setValue:0,unit:'℃',signalID:'radiator'}
          {stateName:'输出电流',setValue:0,unit:'A',signalID:'electric-current'}
          {stateName:'输出频率',setValue:0,unit:'Hz',signalID:'rate'}
          {stateName:'运行天数',setValue:scope.daysRunning,unit:'天',signalID:''}
        ]
        @getDeviceSpecialSignal(scope,scope.equipment,'current-state')
        @getDeviceSpecialSignal(scope,scope.equipment,'abroad')
        @getDeviceSpecialSignal(scope,scope.equipment,'within')
        @getDeviceSpecialSignal(scope,scope.equipment,'radiator')
        @getDeviceSpecialSignal(scope,scope.equipment,'electric-current')
        @getDeviceSpecialSignal(scope,scope.equipment,'rate')
      else if scope.equipment.model.type == 'transformer'
        scope.signalDataArr = [
          {stateName:'当前状态',setValue:'运行',unit:'',signalID:'current-state'}
          {stateName:'运行天数',setValue:scope.daysRunning,unit:'天',signalID:''}
        ]
        @getDeviceSpecialSignal(scope,scope.equipment,'current-state')
      else
        scope.signalDataArr = [
          {stateName:'当前状态',setValue:'运行',unit:'',signalID:'current-state'}
          {stateName:'运行天数',setValue:scope.daysRunning,unit:'天',signalID:''}
        ]
        scope.equipment.loadSignals null,(err,signals)=>
          if err
            return
          else
            for item in signals
              if item.model.group && item.model.group == 'box'
                scope.switchBoxSignals.push(item)
            for j in scope.switchBoxSignals
              scope.signalDataArr.push({stateName:j.model.name,setValue: 0,unit:j.model.definition,signalID:j.model.signal})
              @getDeviceSpecialSignal(scope,scope.equipment,j.model.signal)
#计算设备创建天数
    countDays:(scope)=>
      time = Date.parse(new Date())
      lasttime = Date.parse(scope.equipment.model.createtime)
      if scope.equipment.model.properties.length > 0
        for item in scope.equipment.model.properties
          if item.id == 'production-time'
            lasttime = Date.parse(item.value)
      scope.daysRunning = parseInt((time-lasttime)/(1000*60*60*24))
      console.log(scope.daysRunning)
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
        if signal and signal.message
          for data in scope.signalDataArr
            if signalID == data.signalID
              if signalID == 'current-state'
                console.log signal.message
                if signal.message.value != 0
                  data.setValue = '运行'
                else
                  data.setValue = '停机'
              else
                data.setValue = (signal.message.value).toFixed(2)
    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    DeviceTemperatureDirective: DeviceTemperatureDirective