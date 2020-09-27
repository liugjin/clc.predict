###
* File: task-page-directive
* User: David
* Date: 2019/11/11
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore',
  "moment", 'clc.foundation.angular/models/structure-model', 'gl-datepicker'], (base, css, view, _, moment, sm, gl) ->
  class TaskPageDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService) ->
      @id = "task-page"
      super($timeout, $window, $compile, $routeParams, commonService)

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.query = { 
        taskId: "", state: "", rank: "", 
        startTime: moment().subtract(7, 'days').format("YYYY-MM-DD"),
        endTime: moment().format("YYYY-MM-DD")
      }
      
      scope.modal = M.Modal.getInstance($("#task-modal"))

      scope.search = () => (
        filter = scope.project.getIds()
        filter["createtime"] = {}
        _.mapObject(scope.query, (d, i) =>
          return if d == ''
          if i == "taskId"
            filter["task"] = { $regex: d } 
          else if i == "rank"
            filter["rank"] = d
          else if i == "startTime"
            filter["createtime"]["$gte"] = d
          else if i == "endTime"
            filter["createtime"]["$lte"] = d
          else if i == "state" and d == '1'
            filter["$or"] = [{ "phase.nextManager": null }]
            filter["phase.progress"] = { '$exists': false }
          else if (i == "state" and d == '2')
            filter["$or"] = [{"phase.progress": {'$exists': true, '$gte': 0, '$lt': 1}}, {"phase.nextManager": {'$exists': true }}]
            filter["$nor"] = [{"phase.state": "reject"}, {"phase.state": "cancel"}, {"phase.progress": 1}]
          else if (i == "state" and d == '3')
            filter["phase.progress"] = 1
            filter["$nor"] = [ { "phase.state": "reject" }, { "phase.state": "cancel" } ]
          else if (i == "state" and d == '4')
            filter["phase.state"] = "reject"
          else if (i == "state" and d == '5')
            filter["phase.state"] = "cancel"
        )
        @commonService.publishEventBus("task-query", filter)
      )
      
      setGlDatePicker = (element, value) => (
        return if not value
        setTimeout(() =>
          gl = $(element).glDatePicker({
            dowNames: ["日", "一", "二", "三", "四", "五", "六"],
            monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
            selectedDate: moment(value).toDate()
            onClick: (target, cell, date, data) ->
              month = date.getMonth()+1
              month = "0" + month if month < 10
              day = date.getDate()
              day = "0" + day if day < 10
              target.val(date.getFullYear() + "-" + month + "-" + day).trigger("change")
              
              scope.query.startTime = moment(scope.query.startTime).startOf('day').format('YYYY-MM-DD')
              scope.query.endTime = moment(scope.query.endTime).endOf('day').format('YYYY-MM-DD')
          })
        , 500) 
      )
      
      setGlDatePicker(element.find('#startInput')[0], scope.query.startTime)
      setGlDatePicker(element.find('#endInput')[0], scope.query.endTime)
      
      # 解决左侧菜单显示和隐藏式引起日期选择错位的bug
      scope.myenter = (id) => (
        nowvalue = $('#' + id).offset().left
        $('.gldp-default').css("left", nowvalue + 'px')
        $('.gldp-default').css("position", 'absolute')
      )
      
      # 格式化
      scope.formatDate = (d) => (
        if d == "startInput"
          scope.query.startTime = moment(scope.query.startTime).format('YYYY-MM-DD')
        else if d == "endInput"
          scope.query.endTime = moment(scope.query.endTime).format('YYYY-MM-DD')
      )
            
      scope.subscribeModel?.dispose()
      scope.subscribeModel = @commonService.subscribeEventBus("task-model", (msg) =>
        return if typeof(msg?.message?.open) != "boolean"
        scope.task = msg.message?.task?.task
        if typeof(scope.model?.open) != "function"
          scope.modal = M.Modal.getInstance($("#task-modal"))
          if msg.message.open
            scope.modal.open()
          else
            scope.modal.close()
        else
          if msg.message.open
            scope.modal.open()
          else
            scope.modal.close()
      )
      
    resize: (scope) ->
      scope.subscribeModel?.dispose()

    dispose: (scope) ->


  exports = { TaskPageDirective: TaskPageDirective }
)
    