###
* File: card-border-directive
* User: David
* Date: 2019/12/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define(['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CardBorderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService) ->
      @id = "card-border"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) => (
      scope.title = null
      
      scope.buttonText = null
      
      scope.desc = []

      scope.options = []

      scope.selectOption = (option) => (
        console.log(option)
      )

      scope.$watch("parameters", (param) =>
        return if !param
        _.mapObject(param, (d, i) =>
          if typeof(d) == "string" && scope[i] != d
            scope[i] = d
          else if d instanceof Array
            scope[i] = d
        )
        scope.$applyAsync()
      )
    )

    resize: (scope) ->

    dispose: (scope) ->

  return exports = { CardBorderDirective: CardBorderDirective }
)