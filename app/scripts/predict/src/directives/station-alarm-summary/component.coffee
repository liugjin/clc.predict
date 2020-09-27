###
* File: station-alarm-summary-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationAlarmSummaryDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-alarm-summary"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @setData(scope)
#      scope.stationEventBus?.dispose()
#      scope.stationEventBus = @commonService.subscribeEventBus 'stationID',(msg)=>
#        stationID = msg.message.data
#        @commonService.loadStation stationID, (err,station) =>
#          scope.station = station
#        @setData(scope)
    setData:(scope)=>
## 以下代码参考alarms-monitoring 进行编写
      scope.stationID = scope.station.model.station
      scope.alarmDataArr = []
      scope.alarms = {}
      scope.eventReal = {}
      # 获取告警等级
      scope.severities = scope.project?.dictionary?.eventseverities.items
      #设置数据格式
      scope.alarms[scope.stationID] = {count:0, severity:0, list:{}, severities:{},}
      _.each scope.severities, (severity)->
        scope.alarms[scope.stationID].severities[severity.model.severity] = 0
      subject = new Rx.Subject
      @subscribeEventLive(scope,subject)
      subject.debounce(100).subscribe =>
        @processEvents scope
      @processEvents scope
# 订阅实时告警数据的服务对象
    subscribeEventLive:(scope,subject)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
      scope.eventSubscription?.dispose()
      scope.eventSubscription = @commonService.eventLiveSession.subscribeValues filter, (err, d) =>
        return if not d.message?.event or not scope.alarms[d.message.station]
        event = d.message
        scope.eventReal = {equipmentName:event.equipmentName,eventName:event.eventName}
        key = "#{event.user}.#{event.project}.#{event.station}.#{event.equipment}.#{event.event}.#{event.severity}.#{event.startTime}"
        scope.alarms[event.station].list[key] = event
        delete scope.alarms[event.station].list[key] if event.phase is "completed"
        subject.onNext()

#告警总数  告警等级 每个告警等级的告警数等
    processEvents: (scope) =>
      for key, value of scope.alarms
        _.each scope.severities, (severity)->
          value.severities[severity] = 0
        value.count = (_.keys value.list).length
        value.severity = (_.max(_.filter(_.values(value.list),(item)->not item.endTime), (it)->it.severity))?.severity
        map = _.countBy _.values(value.list), (item)->item.severity
        for key,val of map
          value.severities[key] = val
      currentStation = scope.alarms[scope.stationID]
      currentStation.count == scope.alarms[scope.stationID].count
      currentStation.severity = scope.alarms[scope.stationID].severity if currentStation.severity < scope.alarms[scope.stationID].severity
      for key,val of currentStation.severities
        currentStation.severities[key] == (scope.alarms[scope.stationID].severities[key] ? 0)
      scope.$applyAsync()
      @setAlarmGrade(scope)
# 处理数据让其能在页面展示
    setAlarmGrade:(scope)=>
      scope.alarmDataArr.splice(0,scope.alarmDataArr.length);
      # 遍历处理每个告警等级的告警数
      for grade in scope.severities
        alarmData = {alarmNum:0,alarmName:"",severity:null,imgUrl:""}
        alarmData.alarmNum = @addZero(scope.alarms[scope.stationID].severities[grade.model.severity])
        alarmData.alarmName = grade.model.name
        alarmData.severity = grade.model.severity
        alarmData.imgUrl = "#{@getComponentPath('images/alarm-'+grade.model.severity+".svg")}"
        scope.alarmDataArr.push(alarmData)
      alarmData = {alarmNum:0,alarmName:"",severity:null,imgUrl:""}
      alarmData.alarmNum = @addZero(scope.alarms[scope.stationID].count)
      alarmData.alarmName = "告警总数"
      alarmData.imgUrl = "#{@getComponentPath('images/total-alarm.svg')}"
      scope.alarmDataArr.unshift(alarmData)
# 小于2位数前面补0
    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num
    resize: (scope)->

    dispose: (scope)->
      scope.eventSubscription?.dispose()
  #      scope.stationEventBus?.dispose()

  exports =
    StationAlarmSummaryDirective: StationAlarmSummaryDirective
