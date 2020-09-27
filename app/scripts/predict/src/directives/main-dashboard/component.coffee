###
* File: main-dashboard-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class MainDashboardDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "main-dashboard"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.data = "china"
      @commonService.subscribeEventBus 'map-china',(msg)=>
        if(msg and msg.message)
          scope.data = msg.message.data.model.station
      @commonService.subscribeEventBus 'map-asia',(msg)=>
        if(msg and msg.message)
          scope.data = msg.message.data.model.station

    resize: (scope)->

    dispose: (scope)->


  exports =
    MainDashboardDirective: MainDashboardDirective