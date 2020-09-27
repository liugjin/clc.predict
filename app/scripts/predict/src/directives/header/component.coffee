###
* File: header-directive
* User: David
* Date: 2019/03/08
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class HeaderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "header"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    link: (scope, element, attrs) =>
      scope.setting = setting
      scope.params = @$routeParams
      scope.$watch '$root.user', (root) =>
        try
          scope.rootUser = root.user
        catch err

        scope.switchLanguage = (s) =>
          scope.$parent.mvm.switchLanguage s

        scope.logout = =>
          scope.$parent.mvm.logout()

      scope.getEventColor = (severity) =>
        color = scope.$root.project?.dictionary?.eventseverities?.getItem(severity)?.model.color

      eventStatisticFun = (event) =>
        key = "#{event.user}.#{event.project}.#{event.station}.#{event.equipment}.#{event.event}.#{event.severity}.#{event.startTime}"
        if scope.statisticsEvents.hasOwnProperty key
          if event.endTime and not scope.statisticsEvents[key].endTime
            scope.eventStatistic.activeEvents--
            scope.eventStatistic.eventSeverity.splice scope.eventStatistic.eventSeverity.indexOf(event.severity), 1
            scope.statisticsEvents[key] = event
          if event.phase is 'completed' and not (scope.statisticsEvents[key].phase is 'completed')
            scope.eventStatistic.totalEvents--
            delete scope.statisticsEvents[key]
        else if not (event.phase is 'completed')
          scope.statisticsEvents[key] = event
          if not event.endTime
            scope.eventStatistic.activeEvents++
            scope.eventStatistic.eventSeverity.push event.severity
          scope.eventStatistic.totalEvents++
        scope.eventStatistic.severity = _.max scope.eventStatistic.eventSeverity

      project = null
      scope.$watch 'params', (params) =>
        if params.project
          return if project is params.project
          @getProject scope, =>
            scope.logo = scope.project.model.setting?.logo
          project = params.project
        @statisticSubscription?.dispose()
        scope.statisticsEvents = {}
        scope.eventStatistic = {activeEvents:0,totalEvents:0,severity:0,eventSeverity:[]}
        projectIds =
          user: params.user
          project: params.project
        if projectIds.user
#          if @$window.location.href.indexOf("/dashboard") >=0
#            scope.gameoverSubscription?.dispose()
#            scope.gameoverSubscription=@commonService.subscribeEventBus "3dgameover",()=>
#              @statisticSubscription = @commonService.eventLiveSession.subscribeValues projectIds, (err,d) =>
#                eventStatisticFun d.message if d.message
#          else
            @statisticSubscription = @commonService.eventLiveSession.subscribeValues projectIds, (err,d) =>
              eventStatisticFun d.message if d.message
      ,true

    resize: (scope)->

    dispose: (scope)->
      @statisticSubscription?.dispose()
      scope.gameoverSubscription?.dispose()


  exports =
    HeaderDirective: HeaderDirective