###
* File: frequency-header-directive
* User: bingo
* Date: 2019/06/10
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class FrequencyHeaderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "frequency-header"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>

    resize: ($scope)->

    dispose: ($scope)->


  exports =
    FrequencyHeaderDirective: FrequencyHeaderDirective