###
* File: device-details-component-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceDetailsComponentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-details-component"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      @publishEventBus 'menuState', {'menu': 'menu'}
    resize: (scope)->

    dispose: (scope)->


  exports =
    DeviceDetailsComponentDirective: DeviceDetailsComponentDirective