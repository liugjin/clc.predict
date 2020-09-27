###
* File: ops-info-directive
* User: David
* Date: 2019/11/07
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "rx"], (base, css, view, _, moment, Rx) ->
  class OpsInfoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "ops-info"
      super $timeout, $window, $compile, $routeParams, commonService
      # @eventvaluesService = commonService.modelEngine.modelManager.getService('eventvalues')
      @processtypesService = commonService.modelEngine.modelManager.getService("processtypes")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.switchOrderType = (type) =>(
        scope.switchType = type
        @commonService.publishEventBus("orderType", type)
      )
      # 初始化执行
      init = () => (
        scope.defectOrderType = "故障工单"
        scope.planOrderType = "巡检工单"
        scope.processtypes = []
        scope.allFailureDevice = []
        scope.switchType="all"
        filter = scope.project.getIds()
        @processtypesService.query filter, null, (err, data) =>(
          return @display("查询工单类型失败!!", 500) if !data
          scope.processtypes = data
          _.each scope.processtypes, (item) -> (
            if item.type == "plan"
              scope.planOrderType = item.name
            else if item.type == "defect"
              scope.defectOrderType = item.name
          )
        )
        @getDeviceAlarmInfo(scope)
      )
      init()
    # 获取设备的告警信息
    getDeviceAlarmInfo: (scope) =>
      scope.allDevice = []
      scope.allStation = []
      scope.alarmDeviceCount = 0
      scope.healthDeviceCount = 0
      scope.Rx = new Rx.Subject()
      # 统计设备故障
      statisticalDeviceFailure = () => (
        scope.allFailureDevice = []
        scope.alarmDeviceCount = 0
        whetherExcute = scope.allDeviceCount - 1
        _.each scope.allDevice, (device, num)-> (
          if device.alarmInfo.length > 0
            scope.alarmDeviceCount++
            scope.allFailureDevice.push(device)
          if num == whetherExcute
            scope.healthDeviceCount = scope.allDeviceCount - scope.alarmDeviceCount
            scope.$applyAsync();
        )
      )
      # 订阅设备告警
      subScriptDeviceEventCount = () => (
        statisticalDeviceFailure()
        filter = {
          user: scope.project.model.user
          project: scope.project.model.project
        }
        scope.subAlarmInfo?.dispose()
        scope.subAlarmInfo = @commonService.eventLiveSession.subscribeValues filter, (err, data) => (
          _.each scope.allDevice, (device) -> (
            if device.model.station == data.message.station && device.model.equipment == data.message.equipment
              # 过滤重复的告警,首次进入不执行该函数
              _.each device.alarmInfo, (alarm) ->
                if alarm._index == data.message._index
                  device.alarmInfo = _.filter device.alarmInfo, (item) -> item._index != data.message._index
              device.alarmInfo.push(data.message)
              # 过滤已经结束的告警
              device.alarmInfo = _.filter device.alarmInfo, (item) -> !item.endTime
              if device.alarmInfo.length > 0 then device.state = 1 else device.state = 0

          )
          scope.Rx.onNext()
        )
        # 统计拥有告警的设备
        scope.Rx.debounce(200).subscribe =>
          statisticalDeviceFailure()
      )
      # 获取所有设备
      getAllDevice = () => (
        scope.allDevice = []
        scope.project.loadStations null, (err,stations)=> (
          scope.allStation = stations
          stationCount = scope.allStation.length
          for station, num in scope.allStation
            return if !station
            station.loadEquipments {}, null, (err, equipments) => (
              stationCount--
              _.each equipments, (equipment, num)->
                if(equipment.model.equipment.indexOf("_") == -1)
                  equipment.loadEvents()
                  equipment.alarmInfo = []
                  equipment.state = 0
                  scope.allDevice.push(equipment)
              if stationCount == 0
                scope.allDeviceCount = scope.allDevice.length
                subScriptDeviceEventCount()
            )
        )
      )
      # 开始执行函数
      getAllDevice()

    resize: (scope)->

    dispose: (scope)->
      scope.subAlarmInfo?.dispose()


  exports =
    OpsInfoDirective: OpsInfoDirective
