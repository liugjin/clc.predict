###
* File: station-info-directive
* User: David
* Date: 2019/12/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationInfoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-info"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      @publishEventBus 'menuState', {'menu': 'menu'}
#      console.log 'station',scope.station
      stationImgUrl = "images/#{scope.station.model.station}.png"
      scope.bg = @getComponentPath(stationImgUrl)
      console.log scope.bg
    resize: (scope)->

    dispose: (scope)->


  exports =
    StationInfoDirective: StationInfoDirective