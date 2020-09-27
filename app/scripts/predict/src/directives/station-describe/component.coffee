###
* File: station-describe-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationDescribeDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-describe"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.stationEventBus?.dispose()
      scope.stationEventBus = @commonService.subscribeEventBus 'stationID',(msg)=>
        stationID = msg.message.data
        @commonService.loadStation stationID, (err,station) =>
          scope.station = station
    resize: (scope)->

    dispose: (scope)->
      scope.stationEventBus?.dispose()

  exports =
    StationDescribeDirective: StationDescribeDirective