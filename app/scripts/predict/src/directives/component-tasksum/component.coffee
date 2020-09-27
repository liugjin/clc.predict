###
* File: component-tasksum-directive
* User: David
* Date: 2019/07/17
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'clc.foundation.angular/models/structure-model'], (base, css, view, _, moment,sm) ->
  class ComponentTasksumDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "component-tasksum"
      super $timeout, $window, $compile, $routeParams, commonService
      @timeSubscription = null
      @types ?= new sm.StructureModel 'type'
      @alltaskDatas = []

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @timeSubscription = null
      scope.taskRecNum = 0
      scope.query =
        startTime:moment().subtract(7,"days").startOf('day')
        endTime:moment().endOf('day')
      scope.pieDatas = [
        {orderid:1,name:"等待处理",value:0}
        {orderid:2,name:"已结束",value:0}
        {orderid:3,name:"进行中",value:0}
      ]
#      scope.headers = [
#        {headerName:"", field: "sumoper"},
#        {headerName:"工单总数", field: "tasksum"},
#        {headerName:"等待处理", field: "todo"},
#        {headerName:"进行中", field: "ongoing"},
#        {headerName:"已结束",     field: "finished"},
#      ]
      scope.headers = [
        {headerName:"单号", field: "name"},
        {headerName:"工单类型", field: "typeName"},
        {headerName:"工单状态", field: "statusName"},
        {headerName:"当前执行时间", field: "currexcutetime"},
        {headerName:"负责人",     field: "excutor"},
        {headerName:"创建时间",     field: "creator"},
        {headerName:"创建人",     field: "createtime"}
      ]
      scope.garddatas = [
        {sumoper:"工单汇总",tasksum:"--",todo:"--",ongoing:"--",finished:"--"}
      ]

      @timeSubscription?.dispose()
      @timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      @taskprocessStaticSubscription?.dispose()
      @taskprocessStaticSubscription = @commonService.subscribeEventBus 'task-process-statics',(d)=>
        mesg = d.message
        if @alltaskDatas.length > 0
          scope.garddatas = []
          scope.garddatas = _.filter @alltaskDatas,(item)->
            return item.statusName == mesg.data
          scope.$applyAsync()


      @loadTypes (err,typedatas)=>
        @getTaskDatas(scope)
        scope.$applyAsync()
      ,true

      scope.queryReport = ()=>
        @getTaskDatas(scope)

      scope.exportReport= (header,name)=>
        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
        @commonService.publishEventBus "export-report", {header:header, name:reportName}

    getTaskDatas:(scope)->
      if scope.query.startTime > scope.query.endTime
        @display null, '温馨提示：开始时间晚于结束时间，请查证！'
        return
      scope.pieDatas = [
        {orderid:1,name:"等待处理",value:0}
        {orderid:2,name:"已结束",value:0}
        {orderid:3,name:"进行中",value:0}
      ]
      scope.garddatas = [
        {name:"--",typeName:"--",statusName:"--",currexcutetime:"--",excutor:"--",creator:"--",createtime:"--"}
      ]
      filter = {}
      filter.user = @$routeParams.user
      filter.project = @$routeParams.project
      filter.createtime = {"$gte":scope.query.startTime,"$lte":scope.query.endTime}
      @commonService.loadProjectModelByService 'tasks', filter, '_id user project type process name creator task phase nodes createtime', (err, taskmodels) =>
        return if !taskmodels
        @alltaskDatas = []
        scope.garddatas = []
        scope.taskRecNum = taskmodels.length

        for taskmodelItem in taskmodels
          if (_.isEmpty  taskmodelItem.phase.nextManager) && !(taskmodelItem.phase.progress >= 0)
            #等待处理
            scope.pieDatas[0].value++
          else if (taskmodelItem.phase.progress < 1) || (!_.isEmpty taskmodelItem.phase.nextManager)
            #进行中
            scope.pieDatas[2].value++
          else
            #已结束
            scope.pieDatas[1].value++
          typeModel = _.filter @types.model,(modelItem)->
            return modelItem.type == taskmodelItem.type
          excutor = ""
          if (_.isEmpty taskmodelItem.phase.nextManager) && (taskmodelItem.phase.progress == 1)
            excutor = taskmodelItem.phase.manager.name
          else if _.isEmpty taskmodelItem.phase.nextManager
            excutor = null
          else if !_.isEmpty taskmodelItem.phase.manager
            excutor = taskmodelItem.phase.manager.name
          else if !_.isEmpty taskmodelItem.phase.nextManager
            excutor = taskmodelItem.phase.nextManager.name
          scope.garddatas.push {
            _id:taskmodelItem._id,
            name:taskmodelItem.name,
            typeName:typeModel[0].name,
            statusName:@getStatusName(taskmodelItem.phase.progress,taskmodelItem.phase.state,taskmodelItem.phase.nextManager),
            currexcutetime:(if _.isEmpty taskmodelItem.phase.timestamp then null else moment(taskmodelItem.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
            excutor:excutor
            creator:taskmodelItem.creator?.name,
            createtime:moment(taskmodelItem.createtime).format("YYYY-MM-DD HH:mm:ss")
          }
        for gardatasItem in scope.garddatas
          @alltaskDatas.push gardatasItem



    getStatusName:(progress,state,manager)->
      if (_.isEmpty manager) && !(progress >= 0)
        return "等待处理"
      else if state is "reject"
        return "拒绝"
      else if state is "cancel"
        return "取消"
      else if (progress < 1) || (!_.isEmpty manager)
        return "进行中"
      else
        return "已结束"

    loadTypes:(callback, refresh)->
      @commonService.loadProjectModelByService 'processtypes', {}, 'type name', (err, model) =>
        @types.setItems model

        callback? err, model
      , refresh
    resize: (scope)->

    dispose: (scope)->


  exports =
    ComponentTasksumDirective: ComponentTasksumDirective