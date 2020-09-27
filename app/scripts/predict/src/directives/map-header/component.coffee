###
* File: map-header-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class MapHeaderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "map-header"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @publishEventBus 'menuState', {'menu': 'menu'}
      scope.domShow = false
      scope.headerType = 'map'
      scope.$watch 'parameters.headerType',(headerType)=>
        if headerType == 'map'#地图头部
          scope.headerType = 'map'
          scope.focus = "china"
          scope.centerName = null
          scope.stations = [] #所有站点
          # 获取所有站点
          scope.project.loadStations null, (err, stations)=>
            scope.stations = stations
            @ergodicSite(scope)
          # 订阅点击中国区域的主题
          @commonService.subscribeEventBus 'map-china',(msg)=>
            if(msg and msg.message)
              scope.centerName = msg.message.data.model.name
          # 订阅点击东南亚区域的主题
          @commonService.subscribeEventBus 'map-asia',(msg)=>
            if(msg and msg.message)
              scope.centerName = msg.message.data.model.name
        if headerType == 'scene'#厂房头部
          scope.headerType = 'scene'
          scope.parentStation = scope.station.parentStation.model.name
          scope.centerName = scope.station.model.name
        if headerType == 'device'#设备
          scope.headerType = 'device'
        if headerType == 'device-info'#设备
          scope.headerType = 'device-info'
      scope.clickTime=()=>
        scope.domShow = !scope.domShow
# 对站点进行遍历
    ergodicSite:(scope)=>
      for site in scope.stations
        if site.model.station == scope.focus
          scope.centerName =site.model.name

    resize: (scope)->

    dispose: (scope)->


  exports =
    MapHeaderDirective: MapHeaderDirective