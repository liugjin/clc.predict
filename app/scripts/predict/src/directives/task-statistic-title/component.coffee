###
* File: task-statistic-title-directive
* User: David
* Date: 2019/12/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class TaskStatisticTitleDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "task-statistic-title"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.currdate = moment().subtract(5, "day").format("L") + " ~ " + moment().format("L") 
      scope.typeList = []
      scope.staticsType = null
      scope.typeName = "--"
      scope.title = "--"
      dateMap = {
        day: "YYYY-MM-DD",
        month: "YYYY-MM",
        year: "YYYY"
      }
      # 点击事件
      scope.selectStaticsType = (type) => (
        return if !type
        if type != scope.staticsType
          scope.staticsType = type
          exec = if type == "year" then 3 else 5
          scope.currdate = moment().subtract(exec, type).format(dateMap[type]) + " ~ " + moment().format(dateMap[type]) 
          @commonService.publishEventBus("task-type", { type })
      )

      # 接参 - 初始化
      scope.$watch("parameters", (param) => 
        return if !param
        if _.isNull(scope.staticsType)
          scope.typeList = param.typeList
          scope.typeName = param.typeName
          scope.title = param.title
          scope.selectStaticsType(scope.typeList[0].key)
      )

    resize: (scope)->

    dispose: (scope)->


  exports =
    TaskStatisticTitleDirective: TaskStatisticTitleDirective