###
* File: plantask-card-directive
* User: David
* Date: 2020/01/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'clc.foundation.angular/models/structure-model', "angularGrid"], (base, css, view, _, moment,sm,agGrid) ->
  class PlantaskCardDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "plantask-card"
      super $timeout, $window, $compile, $routeParams, commonService
      @types ?= new sm.StructureModel 'type'

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.oldType = scope.parameters.type
      scope.planExcepItems = []
      scope.planHandlingTasks = []
      scope.allPlanTasks = []
      scope.allPlanWorkItems = []
      scope.reportTitle = ""
      scope.funcType = "execepequips"
      # 巡检工单
      scope.workSeries = [
        { key: "bar", name: "工单", color: "rgb(85, 189, 255)" },
        { key: "line", name: "巡检项", color: "rgb(200, 134, 147)" }
      ]

      scope.rignData = [
        { type:"allworkitems",title: "巡检项总数", val: 30, peresent: 0 },
        { type:"handling",title: "未完成工单数", val: 10, peresent: 0 },
        { type:"execepequips",title: "异常巡检点", val: 10, peresent: 0 }
      ]

      scope.headers = [
        {headerName:"单号", field: "name",width:268},
        {headerName:"工单类型", field: "typeName"},
        {headerName:"工单状态", field: "statusName"},
        {headerName:"当前执行时间", field: "currexcutetime"},
        {headerName:"负责人",     field: "excutor"},
        {headerName:"创建时间",     field: "createtime"},
        {headerName:"创建人",     field: "creator"}
      ]
      scope.garddatas = [
        {name:"--",typeName:"--",statusName:"--",currexcutetime:"--",excutor:"--",createtime:"--",creator:"--"}
      ]

      scope.date = []
      scope.workData = []
      scope.type = "day"
      scope.count = 0
      @loadTypes (err,typedatas)=>

#      scope.gridSubscrib?.dispose()
#      scope.gridSubscrib = @commonService.subscribeEventBus "plantask-grid-single-selection", (msg) =>
#        if msg.message
#          if scope.reportTitle == "未完成工单数"
#            scope.task = msg.message[0].task
#            @commonService.publishEventBus("task-model", msg.message[0].task)
#            $("#singletask-detail-modal").modal('open')

      scope.planringsSubscrib?.dispose()
      scope.planringsSubscrib = @commonService.subscribeEventBus "showrings-plantask", (msg) =>
        scope.funcType = msg.message.id

        if scope.funcType == "execepequips"
          scope.reportTitle = "异常巡检点单明细表"
          scope.headers = [
            {headerName:"单号", field: "name",width:268},
            {headerName:"站点", field: "stationName"},
            {headerName:"设备", field: "equipmentName"},
            {headerName:"巡检点", field: "signalName"},
            {headerName:"工单类型", field: "typeName"},
            {headerName:"工单状态", field: "statusName"},
            {headerName:"当前执行时间", field: "currexcutetime"},
            {headerName:"负责人",     field: "excutor"},
            {headerName:"创建时间",     field: "createtime"},
            {headerName:"创建人",     field: "creator"}
          ]
        else if scope.funcType == "allworkitems"
          scope.reportTitle = "巡检项单明细表"
          scope.headers = [
            {headerName:"单号", field: "name",width:268},
            {headerName:"站点", field: "stationName"},
            {headerName:"设备", field: "equipmentName"},
            {headerName:"巡检点", field: "signalName"},
            {headerName:"工单类型", field: "typeName"},
            {headerName:"工单状态", field: "statusName"},
            {headerName:"当前执行时间", field: "currexcutetime"},
            {headerName:"负责人",     field: "excutor"},
            {headerName:"创建时间",     field: "createtime"},
            {headerName:"创建人",     field: "creator"}
          ]
        else if scope.funcType == "allplantasks"
          scope.reportTitle = "工单明细表"
          scope.headers = [
            {headerName:"单号", field: "name",width:268},
            {headerName:"工单类型", field: "typeName"},
            {headerName:"工单状态", field: "statusName"},
            {headerName:"当前执行时间", field: "currexcutetime"},
            {headerName:"负责人",     field: "excutor"},
            {headerName:"创建时间",     field: "createtime"},
            {headerName:"创建人",     field: "creator"}
          ]
        else if scope.funcType == "handling"
          scope.reportTitle = "未完成工单明细表"
          scope.headers = [
            {headerName:"单号", field: "name",width:268},
            {headerName:"工单类型", field: "typeName"},
            {headerName:"工单状态", field: "statusName"},
            {headerName:"当前执行时间", field: "currexcutetime"},
            {headerName:"负责人",     field: "excutor"},
            {headerName:"创建时间",     field: "createtime"},
            {headerName:"创建人",     field: "creator"}
          ]

        if _.isEmpty scope.allPlanTasks
          scope.planExcepItems = []
          scope.planHandlingTasks = []
          scope.allPlanTasks = []
          scope.allPlanWorkItems = []
          @getPlanTaskInfos(scope,element)
        else if scope.oldType != scope.parameters.type
          scope.planExcepItems = []
          scope.planHandlingTasks = []
          scope.allPlanTasks = []
          scope.allPlanWorkItems = []
          scope.oldType = scope.parameters.type
          @getTotalExcepEquipInfos(scope,element)
        else
          if scope.funcType == "execepequips"
            scope.garddatas = _.clone scope.planExcepItems
          else if scope.funcType == "allworkitems"
            scope.garddatas = _.clone scope.allPlanWorkItems
          else if scope.funcType == "handling"
            scope.garddatas = _.clone scope.planHandlingTasks
          else if scope.funcType == "allplantasks"
            scope.garddatas = _.clone scope.allPlanTasks
          @createGridTable scope,scope.garddatas,scope.headers,element, 'plantask'

        scope.showPlanTaskDetails()


      scope.showPlanTaskDetails = () ->
        $("#plantask-reportdetail-modal").modal('open')
        scope.$applyAsync()

      scope.$watch("parameters", (param) =>
        return if !param

        scope.date = param.date if scope.date.length == 0
        if scope.type != param.type
          scope.type = param.type
          scope.date = param.date

        list = _.map(param.data.workitems, (workitem) -> {
          key: 'line', val: workitem.val, time: workitem.time
        })
        scope.workData = list.concat(_.map(param.data.task, (task) -> {
          key: 'bar', val: task.val, time: task.time
        }))
        count = 0
        handlecounts = 0
        for taskItem in param.data.task
          if !(_.isEmpty taskItem.phase)
            handlecounts += taskItem.val
          count += taskItem.val

        workitemCounts = 0
        for workItem in param.data.workitems
          workitemCounts += workItem.val

        excepworkitemCounts = 0
        for excepworkitem in param.data.excepworkitems
          excepworkitemCounts += excepworkitem.val

        for ringItem in scope.rignData
          if ringItem.type is "handling"
            ringItem.val = handlecounts
            ringItem.title += ": " + handlecounts
          else if ringItem.type is "allworkitems"
            ringItem.val = workitemCounts
            ringItem.title += ": " + workitemCounts
          else if ringItem.type is "execepequips"
            ringItem.val = excepworkitemCounts
            ringItem.title += ": " + excepworkitemCounts
        scope.count = count if scope.count != count
      )


    getPlanTaskInfos:(scope,element)=>
      type = scope.parameters.type
      execCount = if type == "year" then 3 else 5

      # 格式化返回的时间
      formatTypeMap = {
        day: "%Y-%m-%d",
        month: "%Y-%m",
        year: "%Y"
      }
      formatTypeMap2 = {
        day: "MM-DD",
        month: "YYYY-MM",
        year: "YYYY"
      }

      filter = {}
      filter.user = @$routeParams.user
      filter.project = @$routeParams.project
      filter.type = "plan"
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}
      @commonService.loadProjectModelByService 'tasks', filter, '_id user project type process name creator task phase nodes createtime', (err, taskmodels) =>
        return if !taskmodels
        scope.taskRecNum = taskmodels.length

        for taskmodelItem in taskmodels
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

          for equip in taskmodelItem.nodes[0].contents[0].content.content
            if equip.status == 1
              scope.planExcepItems.push {
                _id:taskmodelItem._id,
                task:taskmodelItem.task
                name:taskmodelItem.name,
                typeName:typeModel[0].name,
                stationName:equip.stationName
                equipmentName:equip.equipName
                signalName:equip.signalName
                statusName:@getStatusName(taskmodelItem.phase.progress,taskmodelItem.phase.state,taskmodelItem.phase.nextManager),
                currexcutetime:(if _.isEmpty taskmodelItem.phase.timestamp then null else moment(taskmodelItem.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
                excutor:excutor
                creator:taskmodelItem.creator?.name,
                createtime:moment(taskmodelItem.createtime).format("YYYY-MM-DD HH:mm:ss")
              }

            scope.allPlanWorkItems.push {
              _id:taskmodelItem._id,
              task:taskmodelItem.task
              name:taskmodelItem.name,
              typeName:typeModel[0].name,
              stationName:equip.stationName
              equipmentName:equip.equipName
              signalName:equip.signalName
              statusName:@getStatusName(taskmodelItem.phase.progress,taskmodelItem.phase.state,taskmodelItem.phase.nextManager),
              currexcutetime:(if _.isEmpty taskmodelItem.phase.timestamp then null else moment(taskmodelItem.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
              excutor:excutor
              creator:taskmodelItem.creator?.name,
              createtime:moment(taskmodelItem.createtime).format("YYYY-MM-DD HH:mm:ss")
            }


            scope.allPlanTasks.push {
              _id:taskmodelItem._id,
              task:taskmodelItem.task
              name:taskmodelItem.name,
              typeName:typeModel[0].name,
              statusName:@getStatusName(taskmodelItem.phase.progress,taskmodelItem.phase.state,taskmodelItem.phase.nextManager),
              currexcutetime:(if _.isEmpty taskmodelItem.phase.timestamp then null else moment(taskmodelItem.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
              excutor:excutor
              creator:taskmodelItem.creator?.name,
              createtime:moment(taskmodelItem.createtime).format("YYYY-MM-DD HH:mm:ss")
            }

        scope.planHandlingTasks = _.filter scope.allPlanTasks,(item)->
          return (item.statusName != "拒绝") || (item.statusName != "已结束") || (item.statusName != "取消")
        if scope.funcType == "execepequips"
          scope.garddatas = _.clone scope.planExcepItems
        else if scope.funcType == "allworkitems"
          scope.garddatas = _.clone scope.allPlanWorkItems
        else if scope.funcType == "handling"
          scope.garddatas = _.clone scope.planHandlingTasks
        else if scope.funcType == "allplantasks"
          scope.garddatas = _.clone scope.allPlanTasks

        @createGridTable(scope,scope.garddatas,scope.headers,element, 'plantask')

      ,true

    getTypeName:(id)->
      typeName = id
      switch id
        when 'defect'
          typeName = "故障工单"
        when 'plan'
          typeName = "巡检工单"
        when 'predict'
          typeName = "预测维保"
      typeName

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

    createGridTable: (scope,data,header,element, type) =>
      onSelectionChanged = ()=>
        @commonService.publishEventBus("plantask-grid-single-selection", scope.gridOptions.api.getSelectedRows())

      scope.gridOptions =
        columnDefs: header
        rowData: null
        enableFilter: false
        rowSelection: 'single'
        enableSorting: true
        enableColResize: true
        overlayNoRowsTemplate: "无数据"
        headerHeight:41
        rowHeight: 61
#        onSelectionChanged: onSelectionChanged

      @agrid?.destroy()
      @agrid = new agGrid.Grid element.find("##{type}")[0], scope.gridOptions
      scope.gridOptions.api.sizeColumnsToFit()
      scope.gridOptions.api.setRowData data



    loadTypes:(callback, refresh)->
      @commonService.loadProjectModelByService 'processtypes', {}, 'type name', (err, model) =>
        @types.setItems model

        callback? err, model
      , refresh
    resize: (scope) ->

    dispose: (scope) ->
      scope.gridSubscrib?.dispose()
      scope.planringsSubscrib?.dispose()

  exports =
    PlantaskCardDirective: PlantaskCardDirective