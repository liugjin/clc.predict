###
* File: predicttask-card-directive
* User: David
* Date: 2020/01/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class PredicttaskCardDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "predicttask-card"
      super $timeout, $window, $compile, $routeParams, commonService

    setscope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 维保预测
      scope.count = 0

      scope.data = []

      scope.rings = [
        { key: "一般告警", color: 'rgb(193, 201, 80)', val: 0 },
        { key: "严重告警", color: 'rgb(240, 156, 57)', val: 0 },
        { key: "紧急告警", color: 'rgb(200, 42, 29)', val: 0 }                              
      ]

      scope.series = [
        { key: "task", name: "工单" },
        { key: "equipment", name: "设备" }
      ]

      scope.transData = [{ key: '待处理', val: 0 }, { key: '进行中', val: 0 }]
      scope.equipData = [
        { key: "待处理工单", val: 0, max: 100 }
      ]
      scope.date = []

      scope.$watch("parameters", (param) =>
        return if !param
        scope.date = param.date if scope.date.length == 0
        if scope.type != param.type
          scope.type = param.type
          scope.date = param.date
        
        list = _.map(param.data.equipment, (equip) -> {
          key: 'equipment', val: equip.val, time: equip.time
        })
        scope.data = list.concat(_.map(param.data.task, (task) -> {
          key: 'task', val: task.val, time: task.time
        }))
        
        count = 0
        _.each(param.data.task, (task) => count += task.val)
        scope.count = count if scope.count != count
      )

    resize: (scope)->

    dispose: (scope)->


  exports =
    PredicttaskCardDirective: PredicttaskCardDirective