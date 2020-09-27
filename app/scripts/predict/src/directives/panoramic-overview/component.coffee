###
* File: panoramic-overview-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class PanoramicOverviewDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "panoramic-overview"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.focus = 3
      if scope.station.model.d3
        scope.scene = "/resource/upload/img/public/"+scope.station.model.d3

      else
        scope.scene = ""
      @clickTime(scope)
    clickTime:(scope) =>
      scope.clickTime=(i)=>
        scope.focus = i
        # 发布主题
        if(scope.focus == 1)
          @commonService.publishEventBus "showDevice",{data:i}
        if(scope.focus == 2)
          @commonService.publishEventBus "rotate",{data:i}
        if(scope.focus == 3)
          @commonService.publishEventBus "default",{data:i}

    resize: (scope)->

    dispose: (scope)->


  exports =
    PanoramicOverviewDirective: PanoramicOverviewDirective