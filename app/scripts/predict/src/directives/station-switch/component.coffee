###
* File: station-switch-directive
* User: David
* Date: 2020/02/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationSwitchDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-switch"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 配置站点到路由后 不需要写获取站点的方法
      scope.stations = scope.project.stations.nitems
#      scope.project?.loadStations null, (err, stations) =>
#        if not err
#          stations = _.filter stations,(sta)-> sta.model.parent
#          scope.station = _.min stations,(item)->item.model.index
#          @commonService.publishEventBus "stationID",{data:scope.station.model.station}

      scope.clickStation = (sta)=>
#        @commonService.publishEventBus "stationID",{data:sta.model.station}
        console.log @$routeParams
        window.location.hash = "#/station-info/#{scope.project.model.user}/#{scope.project.model.project}/#{sta.model.station}"    #通过更改路由的方式切换站点
      scope.filterStation = ()->
        (station)=>
          if station.model.parent
            return true
          else
            return false
    resize: (scope)->

    dispose: (scope)->


  exports =
    StationSwitchDirective: StationSwitchDirective