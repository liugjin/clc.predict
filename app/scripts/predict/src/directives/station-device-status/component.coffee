###
* File: station-device-status-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationDeviceStatusDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-device-status"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.station.model.runNumber = '00'
      scope.station.model.offLineNumber = '00'
      scope.station.model.alarmNumber = '00'
      scope.station.model.forecastNumber = '00'
      scope.runEquipment = []#运行设备
      scope.offLineEquipment = []#离线设备
      scope.alarmEquipment = []#告警设备
      scope.forecastEquipment = []#预测设备
      scope.equipSubscription = {}
      console.log("打印当前站点",scope.station)
      # 获取该站点下的所有设备
      scope.station.loadEquipments null, null, (err, equipments)=>
# @getDeviceSignal(scope,equipments)
        @getDeviceSignal(scope,equipments,'communication-status',scope.runEquipment,scope.offLineEquipment,'runState','runNumber','offLineNumber')
        @getDeviceSignal(scope,equipments,'alarm-status',scope.alarmEquipment,scope.forecastEquipment,"alarmState",'forecastNumber','alarmNumber')

#根据信号匹配站点设备状态
# equipments 所有设备数组
# signal 信号ID
# deviceArr1 信号ID为communication-status deviceArr1 = scope.runEquipment 信号ID为alarm-status deviceArr1 = scope.alarmEquipment
# deviceArr2 信号ID为communication-status deviceArr2 = scope.offLineEquipment 信号ID为alarm-status deviceArr2 = scope.forecastEquipment
# setValue 根据对应状态要给设备设定的对象键名
# siteValue1 根据对应状态要给站点设定的对象键名 信号ID为 communication-status siteValue1 = runNumber 信号ID为alarm-status siteValue1 = alarmNumber
# siteValue2 根据对应状态要给站点设定的对象键名 信号ID为 communication-status siteValue2 = offLineNumber 信号ID为alarm-status siteValue2 = forecastNumber
# 获取设备信号 并设置各种状态的设备数量
    getDeviceSignal:(scope,equipments,signalID,deviceArr1,deviceArr2,setValue,siteValue1,siteValue2)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
#        equipment: equipments[0].model?.equipment : '+'
        equipment: '+'
        signal: signalID
      str = scope.station.key + "-"+ signalID
      scope.equipSubscription[str]?.dispose()
      scope.equipSubscription[str] = @commonService.signalLiveSession.subscribeValues filter,(err, d)=>
        if d and d.message
          for equipment in equipments
            if equipment.model.equipment == d.message.equipment
              equipment.model[setValue] = d.message.value# 状态value 值 1告警 0 预测; 1离线 0正常
          deviceArr1.splice(0,deviceArr1.length)
          deviceArr2.splice(0,deviceArr2.length)
          for equipment in equipments
            if equipment.model[setValue] == 1
              deviceArr1.push equipment
            if equipment.model[setValue] == 0
              deviceArr2.push equipment
          scope.station.model[siteValue1] =@addZero(deviceArr1.length)
          scope.station.model[siteValue2] =@addZero(deviceArr2.length)
    addZero:(num)=>
      if (parseInt num < 10 and parseInt num >=0)
        num = '0' + num
      return num

    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()


  exports =
    StationDeviceStatusDirective: StationDeviceStatusDirective