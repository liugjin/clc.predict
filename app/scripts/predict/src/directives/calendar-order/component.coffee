###
* File: calendar-order-directive
* User: David
* Date: 2019/11/14
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "fullcalendar"], (base, css, view, _, moment, fullcalendar) ->
  class CalendarOrderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "calendar-order"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      scope.taskTypes = [
        { name: "总工单数", key: "total", val1: 0, val2: 0 },
        { name: "故障工单数", key: "defect", val1: 0, val2: 0 },
        { name: "运维工单数", key: "plan", val1: 0, val2: 0 },
        { name: "维保工单数", key: "predict", val1: 0, val2: 0 }
      ]
      scope.typeMap = {
        defect: "故障工单", plan: "运维工单", predict: "维保工单"
      }
      scope.stateMap = {
        approval: "已处理", unprocessed: "待处理"
      }
      scope.tasks = []
      scope.ng = {
        calendar: null, # 日历实例对象
        monthStartTime: "", # 月份开始时间
        monthEndTime: "", # 月份结束时间
        workflowData: [], # 所有工单信息
        total: 1, # 当月工单数
        completed: 0, # 当月已处理工单数
        unprocessed: 0, # 当月未处理工单数
        # content: "无",
        monthOrderInfo: [], # 当月工单信息
        recordOrderInfo: [], # 工单记录信息
        onceExecute: true
      }
      scope.modal = M.Modal.getInstance($("#task-modal"))
      # 点击工单记录信息执行的函数
      scope.showOrderDetial = (order) => (
        scope.task = order.id
        if typeof(scope.modal?.open) == "function"
          @commonService.publishEventBus("task-model",  order.id)
          scope.modal.open()
        else
          scope.modal = M.Modal.getInstance($("#task-modal"))
          @commonService.publishEventBus("task-model", order.id)
          scope.modal.open()
      )
      # 清空数据已处理数和未处理数
      emptyTotalNumber = () => (
        eventNum = $(element).find('.workflow-table .fc-body .fc-week .fc-content-skeleton .fc-event-container').length
        if eventNum == 0
          scope.ng.total = 1
          scope.ng.completed = 0
          scope.ng.unprocessed = 0
          scope.$applyAsync()
      )
      # 获取运维工单数据
      setTaskData = (err, taskModels) => (
        scope.ng.workflowData = _.map taskModels, (task) => (
          id = task?.task
          createtime = moment(task.createtime).local().format("YYYY-MM-DD HH:mm")
          updatetime = moment(task.updatetime).local().format("YYYY-MM-DD HH:mm")
          name = task.name
          nodes = task.nodes
          phase = task.phase.nextNode
          color = ""
          state = ""
          # **************************这里要加多个红色的
          # if(phase == null)
          #   color = "#32CA59" # 绿色
          #   state = "approval"
          # else
          #   color = "#DFB145" # 黄色
          #   state = "unprocessed"
          if !@getStatus(task.phase)
            color = "#32CA59" # 绿色
            state = "approval"
          else
            color = "#DFB145" # 黄色
            state = "unprocessed"  
          return {
            id: id,
            title: name,
            color: color,
            start: createtime,
            createtime: createtime,
            # end: updatetime,
            updatetime: updatetime,
            state: state,
            content: nodes,
            type: task.type
          }
        )
        scope.ng.workflowData = _.filter scope.ng.workflowData, (item)->
          item != undefined
        
        drawWorkflow()
        if(scope.ng.onceExecute)
          getUnprocessedOrder()
      )
      
      getWorkflowData = () => (
        @commonService?.loadProjectModelByService('tasks', {}, null, setTaskData, true)
      )
      # 获取待处理工单
      getUnprocessedOrder = () => (
        scope.ng.recordOrderInfo = _.filter scope.ng.monthOrderInfo, (order) -> (
          order.state == "unprocessed"
        )
      )
      # 绘制日历表
      drawWorkflow = () => (
        options = {
          plugins: [ 'dayGrid', 'timeGrid' ],
          lang: 'zh-cn'
          header: {
            left: 'prev,next today',
            center: 'title',
            right: ''
          },
          buttonText:{
            prev: '◀',
            next: '▶'
          },
          contentHeight: '90vh',
          timeFormat: "H:mm"
          # 点击工单条触发的事件
          eventClick: (data, event, table) -> (
            scope.showOrderDetial(data)
          ),
          # 切换日历后执行
          # eventAfterRender: (data,event) -> (
          #   if data.createtime >= scope.ng.monthStartTime && data.createtime <= scope.ng.monthEndTime
          #     scope.ng.total++
          #     scope.ng.monthOrderInfo.push(data)
          #     if data.state is "unprocessed" then scope.ng.unprocessed++ else scope.ng.completed++
          #     scope.$applyAsync()
          # )
          # 切换日历日期时执行
          eventRender: (data, event, table)-> (
            scope.ng.monthStartTime =  moment(table.intervalStart._d).startOf('month').format('YYYY-MM-DD ') + "00:00:00"
            scope.ng.monthEndTime = moment(table.intervalStart._d).endOf('month').format('YYYY-MM-DD ') + "23:59:59"
            scope.ng.total = 0
            scope.ng.completed = 0
            scope.ng.unprocessed = 0
            map = {}
            _.each(scope.taskTypes, (type, index) => 
              type.val1 = 0
              type.val2 = 0
              map[type.key] = index
            )
            scope.tasks = _.map(_.filter(scope.ng.workflowData, (task) => 
              return moment(scope.ng.monthStartTime).isBefore(task.createtime) and moment(task.createtime).isBefore(scope.ng.monthEndTime)
            ), (d) => (
              if d.state == "approval"
                scope.taskTypes[map[d.type]].val1++ 
                scope.taskTypes[map["total"]].val1++ 
              else
                scope.taskTypes[map[d.type]].val2++
                scope.taskTypes[map["total"]].val2++ 
              return d
            ))
            scope.ng.monthOrderInfo = scope.tasks
            scope.$applyAsync()
            # console.log(scope.taskTypes, scope.tasks)
          )
          events: scope.ng.workflowData
        }
        scope.ng.calendar = new fullcalendar.Calendar element.find('.workflow-table'), options
        scope.ng.calendar.render()
        dom = '<div class="completed-bar"></div>
              <div class="completed">已处理</div>
              <div class="unprocessed-bar"></div>
              <div class="unprocessed">待处理</div>'
              # <div class="overtime-unprocessed-bar"></div>
              # <div class="overtime-unprocessed">超时未处理</div>'
        # 当跳转的页面没有事件时,清空统计数量
        $(element).find(".workflow-table .fc-toolbar .fc-left").find(".fc-prev-button").on("click",()->
          emptyTotalNumber()
          getUnprocessedOrder()
        )
        $(element).find(".workflow-table .fc-toolbar .fc-left").find(".fc-next-button").on("click",()->
          emptyTotalNumber()
          getUnprocessedOrder()
        )
        $(dom).appendTo(element.find('.task-workflow-box .fc-toolbar .fc-right'))
      )
      # 初始化执行
      init = () => (
        # 避免切换站点时渲染出多个日历表
        $(element).find(".workflow-table").children().remove()
        scope.subscribeOrderType?.dispose()
        scope.subscribeOrderType = @commonService.subscribeEventBus "orderType", (data) => (
          return if !data
          map1 = {
            "总工单数": "total",
            "故障工单数": "defect",
            "运维工单数": "plan",
            "维保工单数": "predict"
          }
          map2 = {
            "已处理": "approval",
            "待处理": "unprocessed"
          }
          if map1[data.message.seriesName] == "total" && data.message.name != "总量"
            scope.tasks = _.filter(scope.ng.monthOrderInfo, (o) => map2[data.message.name] == o.state)
          else if map1[data.message.seriesName] != "total" && data.message.name != "总量"
            scope.tasks = _.filter(scope.ng.monthOrderInfo, (o) => o.type == map1[data.message.seriesName] && map2[data.message.name] == o.state)
          else if map1[data.message.seriesName] == "total" && data.message.name == "总量" 
            scope.tasks = scope.ng.monthOrderInfo
          else if map1[data.message.seriesName] != "total" && data.message.name == "总量" 
            scope.tasks = _.filter(scope.ng.monthOrderInfo, (o) => o.type == map1[data.message.seriesName])
          scope.$applyAsync()
          # console.log(scope.tasks)
        )
        # 订阅工单
        user = scope.$root.user.user
        topic = "tasks/#{user}/#"
        scope.maintasksSubscri?.dispose()
        scope.maintasksSubscri = @commonService.configurationLiveSession.subscribe topic, (err, order) =>
          return if not order
          getWorkflowData()
        getWorkflowData()
      )
      init()

      scope.subModel?.dispose()
      scope.subModel = @commonService.subscribeEventBus("task-model", (msg) => 
        if typeof(msg?.message?.open) == "boolean" && !msg?.message?.open
          scope.modal.close()
      )
      
      scope.subQuery?.dispose()
      scope.subQuery = @commonService.subscribeEventBus("task-query", (msg) => 
        if typeof(msg?.message) == "string"
          getWorkflowData()
      )
      
    getStatus: (phase) ->
      state = phase?.state
      manager = phase?.nextManager
      progress = phase?.progress
      if _.isEmpty(manager) && !(progress >= 0)
        return true
      else if state is "reject"
        return false
      else if state is "cancel"
        return false
      else if (progress < 1) || !_.isEmpty(manager)
        return true
      else
        return false
    
    resize: (scope)->

    dispose: (scope)->
      scope.subModel?.dispose()
      scope.subQuery?.dispose()
      scope.maintasksSubscri?.dispose()
      scope.subscribeOrderType?.dispose()


  exports =
    CalendarOrderDirective: CalendarOrderDirective