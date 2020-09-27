###
* File: forecast-results-list-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ForecastResultsListDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "forecast-results-list"
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
#          scope.eventSubscriptionArray.forEach (sub)=>
#            sub.dispose()
#          @setData(scope,element)

      scope.inverterImg = @getComponentPath('images/inverter.svg')
      scope.motorImg = @getComponentPath('images/motor.svg')
      scope.switchboxImg = @getComponentPath('images/switch-box.svg')
      scope.transformerImg = @getComponentPath('images/transformer.svg')
      scope.typeImages = {}


    setData:(scope)=>
      scope.events = {}
      scope.eventsArray = []
      scope.eventSubscriptionArray = []
      scope.eventsArray.splice(0,scope.eventsArray.length)
      @subscribeValues(scope)
    subscribeValues:(scope)=>
      # 订阅告警信息
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
      eventSubscription=@commonService.eventLiveSession.subscribeValues filter,(err,msg) =>
        return console.log(err) if err
        @processEvent(scope,msg)
      scope.eventSubscriptionArray.push(eventSubscription)
    # 处理订阅回来的告警
    processEvent:(scope,data) =>
      return if not data
      message = data.message
      switch message.equipmentType
        when 'inverter'
          message.typeImg = scope.inverterImg
        when 'motor'
          message.typeImg = scope.motorImg
        when 'switch-box'
          message.typeImg = scope.switchboxImg
        when 'transformer'
          message.typeImg = scope.transformerImg
      key = "#{message.user}.#{message.project}.#{message.station}.#{message.equipment}.#{message.event}.#{message.severity}.#{message.startTime}"
      if scope.events.hasOwnProperty key
        event = scope.events[key]
        for k, v of message
          event[k] = v
      else
        event = angular.copy message
        scope.events[key] = event
        if(event.eventType == "divine" and event.phase == "start")
          scope.eventsArray.unshift(event)

      # 跳转页面
      scope.clickEvent = (event)=>
#        console.log event
        window.location.hash = "#/device-details/#{event.user}/#{event.project}/#{event.station}/#{event.equipment}"
    resize: (scope)->

    dispose: (scope)->
#      scope.stationEventBus?.dispose()
      scope.eventSubscriptionArray.forEach (sub)=>
        sub.dispose()

  exports =
    ForecastResultsListDirective: ForecastResultsListDirective