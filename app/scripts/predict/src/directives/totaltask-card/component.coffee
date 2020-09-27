###
* File: totaltask-card-directive
* User: David
* Date: 2020/01/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'clc.foundation.angular/models/structure-model'], (base, css, view, _, moment,sm) ->
  class TotaltaskCardDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "totaltask-card"
      super $timeout, $window, $compile, $routeParams, commonService
      @types ?= new sm.StructureModel 'type'

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.oldHandlingType = scope.parameters.type
      scope.oldExcepType = scope.parameters.type
      scope.totaltaskReportDatas = []
      scope.handlingReportDatas = []
      scope.execepReportDatas = []
      scope.reportTitle = ""
      scope.showVertical = false
      scope.count = 0
      scope.data = [
        { id: "task-defect", key: "故障工单", stack: "待处理工单", val: 0, sort: 0 },
        { id: "task-plan", key: "巡检工单", stack: "待处理工单", val: 0, sort: 1 },
        { id: "task-predict", key: "维保工单", stack: "待处理工单", val: 0, sort: 2 },
        { id: "excepequips-defect", key: "故障设备", stack: "异常设备", val: 0, sort: 0 },
        { id: "excepequips-plan", key: "巡检设备", stack: "异常设备", val: 0, sort: 1 },
        { id: "excepequips-predict", key: "维保设备", stack: "异常设备", val: 0, sort: 2 }
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
      @loadTypes (err,typedatas)=>
      scope.changeVertical = () => (
        scope.showVertical = !scope.showVertical
        scope.$applyAsync()
      )


      scope.handlingSubscipt?.dispose()
      scope.handlingSubscipt = @commonService.subscribeEventBus 'component-totaltask-handingsheets',(msg)=>
        scope.reportTitle = "待处理工单明细表"
        scope.headers = [
          {headerName:"单号", field: "name",width:268},
          {headerName:"工单类型", field: "typeName"},
          {headerName:"工单状态", field: "statusName"},
          {headerName:"当前执行时间", field: "currexcutetime"},
          {headerName:"负责人",     field: "excutor"},
          {headerName:"创建时间",     field: "createtime"},
          {headerName:"创建人",     field: "creator"}
        ]
        if _.isEmpty scope.handlingReportDatas
          @getTotalHandlingWorkTaskInfos(scope)
        else if scope.oldHandlingType != scope.parameters.type
          scope.handlingReportDatas = []
          scope.oldHandlingType = scope.parameters.type
          @getTotalHandlingWorkTaskInfos(scope)
        else
          scope.garddatas = _.clone scope.handlingReportDatas
        scope.showTotalDetails()

      scope.excepequipSubscipt?.dispose()
      scope.excepequipSubscipt = @commonService.subscribeEventBus 'component-totaltask-excepequips',(msg)=>
        scope.reportTitle = "异常设备明细表"
        scope.headers = [
          {headerName:"单号", field: "name",width:268},
          {headerName:"站点", field: "stationName"},
          {headerName:"设备", field: "equipmentName"},
          {headerName:"工单类型", field: "typeName"},
          {headerName:"工单状态", field: "statusName"},
          {headerName:"当前执行时间", field: "currexcutetime"},
          {headerName:"负责人",     field: "excutor"},
          {headerName:"创建时间",     field: "createtime"},
          {headerName:"创建人",     field: "creator"}
        ]
        if _.isEmpty scope.execepReportDatas
          @getTotalExcepEquipInfos(scope)
        else if scope.oldExcepType != scope.parameters.type
          scope.execepReportDatas = []
          scope.oldExcepType = scope.parameters.type
          @getTotalExcepEquipInfos(scope)
        else
          scope.garddatas = _.clone scope.execepReportDatas
        scope.showTotalDetails()

      scope.showTotalDetails = () ->
        $("#totaltask-reportdetail-modal").modal('open')
        scope.$applyAsync()

      scope.gridSubscrib?.dispose()
      scope.gridSubscrib = @commonService.subscribeEventBus "grid-single-selection", (msg) =>
        if msg.message
          if scope.reportTitle == "待处理工单明细表"
            scope.task = msg.message[0].task
            @commonService.publishEventBus("task-model", msg.message[0].task)
            $("#singletask-detail-modal").modal('open')

      scope.exportReport= (header,name)=>
        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
        @commonService.publishEventBus "export-report", {header:header, name:reportName}

      scope.$watch("parameters", (param) =>
        console.info param
        _.each(scope.data, (d, i) => scope.data[i].val = 0)
        _.mapObject(param.data, (d, i) =>
          if i == "task"
            _.each(d, (item) =>
              if !(_.isEmpty item.phase)
                key = i + "-" + item.type
                index = _.findIndex(scope.data, (m) => m.id == key)
                if index > -1
                  scope.data[index].val += item.val
            )
          else if i == "excepequips"
            _.each(d, (item) =>
              key = i + "-" + item.type
              index = _.findIndex(scope.data, (m) => m.id == key)
              if index > -1
                scope.data[index].val += item.val
            )
          else if i == "equipment"
            tmpDefects = _.filter param.data["equipment"],(equipItem)->
              return equipItem.type == "defect"
            if tmpDefects.length > 0
              index = _.findIndex(scope.data, (m) => m.id == "excepequips-defect")
              for defectItem in tmpDefects
                scope.data[index].val += defectItem.val
      )

        count = 0
        _.each(param.data.task, (task) => count += task.val)
        if scope.count != count
          scope.count = count
      )

    getTotalExcepEquipInfos:(scope)=>
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
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}
      @commonService.loadProjectModelByService 'tasks', filter, '_id user project type process name creator task phase nodes createtime', (err, taskmodels) =>
        return if !taskmodels
        scope.taskRecNum = taskmodels.length

        for taskmodelItem in taskmodels
          if taskmodelItem.type == "defect"
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
            scope.execepReportDatas.push {
              _id:taskmodelItem._id,
              task:taskmodelItem.task
              name:taskmodelItem.name,
              typeName:typeModel[0].name,
              stationName:taskmodelItem.source?.stationName
              equipmentName:taskmodelItem.source?.equipmentName
              statusName:@getStatusName(taskmodelItem.phase.progress,taskmodelItem.phase.state,taskmodelItem.phase.nextManager),
              currexcutetime:(if _.isEmpty taskmodelItem.phase.timestamp then null else moment(taskmodelItem.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
              excutor:excutor
              creator:taskmodelItem.creator?.name,
              createtime:moment(taskmodelItem.createtime).format("YYYY-MM-DD HH:mm:ss")
            }
          else if taskmodelItem.type == "plan"
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
            oldEquipid = ""
            for equip in taskmodelItem.nodes[0].contents[0].content.content
              if equip.status == 1
                equipid = equip.stationName+equip.equipName
                if oldEquipid != equipid
                  oldEquipid = equipid
                  scope.execepReportDatas.push {
                    _id:taskmodelItem._id,
                    task:taskmodelItem.task
                    name:taskmodelItem.name,
                    typeName:typeModel[0].name,
                    stationName:equip.stationName
                    equipmentName:equip.equipName
                    statusName:@getStatusName(taskmodelItem.phase.progress,taskmodelItem.phase.state,taskmodelItem.phase.nextManager),
                    currexcutetime:(if _.isEmpty taskmodelItem.phase.timestamp then null else moment(taskmodelItem.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
                    excutor:excutor
                    creator:taskmodelItem.creator?.name,
                    createtime:moment(taskmodelItem.createtime).format("YYYY-MM-DD HH:mm:ss")
                  }
        scope.garddatas = _.clone scope.execepReportDatas
#        for gardatasItem in scope.garddatas
#          @alltaskDatas.push gardatasItem
      ,true

    getTotalHandlingWorkTaskInfos:(scope)=>
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
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}
#      filter = _.extend filter,{"phase.nextNode":null}
      @commonService.loadProjectModelByService 'tasks', filter, '_id user project type process name creator task phase nodes createtime', (err, taskmodels) =>
        return if !taskmodels
        scope.taskRecNum = taskmodels.length

        for taskmodelItem in taskmodels
          if !(_.isEmpty taskmodelItem.phase.nextNode)
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
            scope.handlingReportDatas.push {
              _id:taskmodelItem._id,
              name:taskmodelItem.name,
              task:taskmodelItem.task
              typeName:typeModel[0].name,
              statusName:@getStatusName(taskmodelItem.phase.progress,taskmodelItem.phase.state,taskmodelItem.phase.nextManager),
              currexcutetime:(if _.isEmpty taskmodelItem.phase.timestamp then null else moment(taskmodelItem.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
              excutor:excutor
              creator:taskmodelItem.creator?.name,
              createtime:moment(taskmodelItem.createtime).format("YYYY-MM-DD HH:mm:ss")
            }
        scope.garddatas = _.clone scope.handlingReportDatas
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

    loadTypes:(callback, refresh)->
      @commonService.loadProjectModelByService 'processtypes', {}, 'type name', (err, model) =>
        @types.setItems model

        callback? err, model
      , refresh

    resize: (scope)->

    dispose: (scope)->
      scope.gridSubscrib?.dispose()
      scope.handlingSubscipt?.dispose()
      scope.excepequipSubscipt?.dispose()

  exports =
    TotaltaskCardDirective: TotaltaskCardDirective