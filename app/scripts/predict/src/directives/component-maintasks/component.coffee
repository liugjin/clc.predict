###
* File: component-maintasks-directive
* User: James
* Date: 2019/06/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define [
  '../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",
  'clc.foundation.angular/models/structure-model', "text!./taskmodal/moudle.html"], (base, css, view, _, moment, sm, tableMoudle) ->
  class ComponentMaintasksDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "component-maintasks"
      super $timeout, $window, $compile, $routeParams, commonService
      @maintasksSubscri = null
      @equipSubscription = {}
      @timeSubcrib = null
      @processes ?= new sm.StructureModel 'process'
      @types ?= new sm.StructureModel 'type'
      @allTasksModels = []
      @taskService = commonService.modelEngine.modelManager.getService("tasks")
      @taskRecordService = commonService.modelEngine.modelManager.getService("reporting.records.task")
      @TASK_TYPE = "unmanned-work"
      @TASK_PROCESS = "unmanned-process"
      @managers = new sm.StructureModel('id')

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.selectNode = null
      scope.selectedTask = null
      @checkAllValues = {}

      @current = {}
      @newTaskModel = {
        user:@$routeParams.user
        project:@$routeParams.project
        type: @TASK_TYPE
        process: @TASK_PROCESS
      }
      scope.detailGreenImg = @getComponentPath('image/detail-green.svg')
      scope.editGreenImg = @getComponentPath('image/edit-green.svg')
      scope.deleteGreenImg = @getComponentPath('image/delete-green.svg')
      scope.copyGreenImg = @getComponentPath('image/copy-green.svg')
      scope.workFlag = true
      scope.workBtnFlag = true
      scope.detailFlag = false
      scope.receiveFlag = false
      scope.currTask =
        memo:""
        name:""
      scope.checkContent = []
      @resetContent(scope)
      scope.tasks =[]
      @timeSubcrib?.dispose()
      @timeSubcrib = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      scope.query =
        startTime:moment().subtract(7,"days").startOf('day')
        endTime:moment().endOf('day')

      @subscribeStationSignlVal(scope)

      scope.showTaskInfo = (operFlag)=>
          if operFlag == 1
            scope.workFlag = true
            scope.detailFlag = false
          else
            scope.workFlag = false
            scope.detailFlag = true

      scope.handleTask = (taskItem)=>
#        console.log("handleTask", taskItem)
        @resetContent(scope)
        scope.currTask.name = taskItem.name
        taskResult = _.filter @allTasksModels,(model)->
          return model._id == taskItem._id

        if taskResult.length > 0
          scope.selectedTask = taskResult[0]
          scope.current = @current = taskResult[0]
          scope.nodedatas = taskResult[0].nodes
          noddedataResult = _.filter scope.nodedatas,(nodedata)->
            return nodedata.node == scope.selectedTask.phase.nextNode
          scope.selectNode = noddedataResult[0]

          if (_.isEmpty scope.current.phase.nextManager) && !(scope.current.phase.progress >=0)
            scope.receiveFlag = true
          else
            scope.receiveFlag = false

          if scope.$root.user.user == scope.selectNode?.manager?.id && scope.selectedTask.phase.progress != 1
            scope.workFlag = true
            scope.workBtnFlag = true
            scope.detailFlag = false
          else
            scope.workFlag = false
            scope.workBtnFlag = false
            scope.detailFlag = true

      scope.deleteTask = (taskItem)=>
        taskResult = _.filter @allTasksModels,(model)->
          return model._id == taskItem._id
        if taskResult.length > 0
          @current = taskResult[0]
          @taskService.remove taskResult[0],(err,taskdata)=>
            if err
              @display err,taskdata
            else
              @getTaskDatas(scope)
              scope.$applyAsync()
              @display "温馨提示：操作成功！"

      scope.selectTaskData=(taskItem)=>
        scope.currTask.name = taskItem.name
        taskResult = _.filter @allTasksModels,(model)->
          return model._id == taskItem._id
        if taskResult.length > 0
          scope.nodedatas = taskResult[0].nodes

      scope.queryReport = ()=>
        @getTaskDatas(scope)
        scope.$applyAsync()

      scope.addTask = ()=>
#        @getTaskMaxNo (taskno)=>
#          scope.currTask.name = taskno

          @newTaskModel = {
            user:@$routeParams.user
            project:@$routeParams.project
            type: @TASK_TYPE
            process: @TASK_PROCESS
            creator:
              id:scope.$root.user.user
              name:scope.$root.user.name
          }
          scope.$applyAsync()
      scope.saveTask = ()=>
        taskResult = _.filter scope.tasks,(taskitem)->
          return taskitem.name == scope.currTask.name
        if taskResult.length > 0
          @display "该工单号已存在，请查证！"
          return
#        @newTaskModel.name = scope.currTask.name
        @taskService.save @newTaskModel,(err,taskdata)=>
          taskdata.nodes[0].contents = []
          taskdata.nodes[0].contents[0]=scope.checkContent
          taskdata.nodes[0].contents[1] = scope.currTask.memo
          @current = taskdata
#          @updateNode scope,taskdata.nodes[0],"approval",(err,result)=>
          @getTaskDatas(scope)
          @display "温馨提示：操作成功！"
          scope.$applyAsync()

      scope.handleTaskOper=(action)=>
        tmpAllVals = _.values @checkAllValues
        for item in tmpAllVals
          if !item
            @display "温馨提示：有部分漏巡检，请查证！"
            return
        if _.isEmpty scope.selectNode.contents
          scope.selectNode.contents = []
          scope.selectNode.contents[0] = scope.checkContent
          scope.selectNode.contents[1] = scope.currTask.memo
        else
          scope.checkContent.push scope.currTask.memo
          scope.selectNode.contents.push {content:scope.checkContent}
        @updateNode scope,scope.selectNode,action,(err,result)=>
          @getTaskDatas(scope)
          @display "温馨提示：操作成功！"
          scope.$applyAsync()

      scope.checkedChange = (objId,data)=>
        @checkAllValues[objId] = data

      scope.acceptWorkSheet = ()=>
        @acceptNode scope,scope.selectNode,(err,result)=>
          @getTaskDatas(scope)
          @display "温馨提示：操作成功！"
          scope.$applyAsync()

      @loadTypes (err,typedatas)=>
          @getTaskDatas(scope)
          scope.$applyAsync()
      ,true

#      @getTaskMaxNo (maxnodata)=>
#        console.info maxnodata



    loadTypes:(callback, refresh)->
      @commonService.loadProjectModelByService 'processtypes', {}, 'type name', (err, model) =>
        @types.setItems model

        callback? err, model
      , refresh

    loadManagers:(callback, refresh)->
      @commonService.loadProjectModelByService 'groups', {}, 'group engineers name', (err, model) =>
        if model
          engineers = []

          for m in model
            for e in m.engineers
              engineers.push e

        @managers.setItems engineers

        callback? err, model
      , refresh

    loadProcesses: (callback, refresh) ->
      @commonService.loadProjectModelByService 'processes', {}, 'type process name', (err, model) =>
        @processes.setItems model
        @processes.groupBy 'type'

        callback? err, model
      , refresh

    subscribeMyTasks:(scope)->
      user = scope.$root.user.user
      topic = "tasks/#{user}/#"
#      console.log "subscribe to #{topic}"

      @maintasksSubscri?.dispose()
      @maintasksSubscri = @commonService.configurationLiveSession.subscribe topic, (err,d) =>
        return if not d

        if d.topic.indexOf("configuration/task/create/") is 0 or d.topic.indexOf("configuration/task/update/") is 0
          taskmodel = d.message
          tmpTaskModel = _.where @allTasksModels,{_id:taskmodel._id}

          if _.isEmpty tmpTaskModel
             @allTasksModels.push d.message
          else
            tmpTaskModel.name = taskmodel.name
            tmpTaskModel.trigger = taskmodel.trigger
            tmpTaskModel.nodes = taskmodel.nodes
            tmpTaskModel.enable = taskmodel.enable
            tmpTaskModel.visible = taskmodel.visible
            tmpTaskModel.phase = taskmodel.phase
            tmpTaskModel.updatetime = taskmodel.updatetime

          tmpTaskResult = _.where scope.tasks,{_id:taskmodel._id}


          typeModel = _.filter @types.model,(modelItem)->
            return modelItem.type == taskmodel.type
          if _.isEmpty tmpTaskResult
            tmpExcuteTime = null
            if _.isEmpty(taskmodel?.phase.timestamp)
              tmpExcuteTime = null
            else
              tmpExcuteTime = moment(taskmodel?.phase?.timestamp).format("YYYY-MM-DD HH:mm:ss")
            scope.tasks.push {
              _id:taskmodel._id,
              name:taskmodel.name,
              typeName:typeModel[0].name,
              statusName:@getStatusName(taskmodel.phase.progress,taskmodel.phase.state,taskmodel.phase.nextManager),
              currexcutetime:tmpExcuteTime,
              excutor:taskmodel.phase?.manager?.name,
              creator:taskmodel.creator.name,
              createtime:moment(taskmodel.createtime).format("YYYY-MM-DD HH:mm:ss")
            }
          else
            tmpTaskResult.name = taskmodel.name
            tmpTaskResult.typeName = typeModel[0].name
            tmpTaskResult.statusName = @getStatusName(taskmodel.phase.progress,taskmodel.phase.state,taskmodel.phase.nextManager)
            tmpTaskResult.currexcutetime = moment(taskmodel.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")
            tmpTaskResult.excutor = taskmodel.phase.manager?.name
            tmpTaskResult.creator = taskmodel.creator.name
            tmpTaskResult.createtime = moment(taskmodel.createtime).format("YYYY-MM-DD HH:mm:ss")

          scope.$applyAsync()
        else if d.topic.indexOf("configuration/task/delete/") is 0
          id = d.message._id
          itemIndex = _.findIndex scope.tasks,(taskItem)->
            return taskItem._id = id
          if itemIndex>=0
            scope.tasks.slice(itemIndex+1)
            scope.$applyAsync()
      , false, null

    resetContent: (scope) ->
      $("#detail-table").empty() if $("#detail-table").children.length > 0
      html = _.clone(tableMoudle);
      content = if _.has(@current, "nodes") then @current.nodes[0].contents[0].content else {
        severities: ["--", "--", "--"]
        ups1: { alarms: "--", loadRate: "--" }
        ups2: { alarms: "--", loadRate: "--" }
        distributor: { alarms: "--", voltage: "--", temperature: "--", humidity: "--"  }
        battery: { alarms: "--", temperature: "--", humidity: "--" }
        ac1: { alarms: "--", status: "--" }
        ac2: { alarms: "--", status: "--" }
        ac3: { alarms: "--", status: "--" }
        dme1: { alarms: "--", status: "--" }
        dme2: { alarms: "--", status: "--" }
        th1: { alarms: "--", temperature: "--", humidity: "--" }
        th1: { alarms: "--", temperature: "--", humidity: "--" }
        th2: { alarms: "--", temperature: "--", humidity: "--" }
        th3: { alarms: "--", temperature: "--", humidity: "--" }
        th4: { alarms: "--", temperature: "--", humidity: "--" }
        th5: { alarms: "--", temperature: "--", humidity: "--" }
        th6: { alarms: "--", temperature: "--", humidity: "--" }
        th7: { alarms: "--", temperature: "--", humidity: "--" }
        water1: "--"
        water2: "--"
        water3: "--"
        water4: "--"
        water5: "--"
        comment: ""
      }
      counts = { ups: 2, ac: 3, dme: 2, th: 7, water: 5 }
      datas = ["ups-alarms", "ups-loadRate", "distributor-alarms", "distributor-voltage","battery-alarms",
        "battery-temperature", "battery-humidity", "ac-status", "dme-status", "th-alarms", "th-temperature",
        "th-humidity", "water-alarms", "distributor-temperature", "distributor-humidity"
      ]
      _.map(datas, (item) =>
        items = item.split("-")
        count = if _.has(counts, items[0]) then counts[items[0]] else 1
        for x in [1..count]
          _index = if (items[0] is "distributor" or items[0] is "battery") then items[0] else (items[0] + x)
          _val = content[_index]?[items[1]]
          replaceVal = ""
          if typeof(_val) is "object" and (items[1] is "loadRate" or items[1] is "voltage")
            replaceVal = _.max(_.values(_val))
          else if typeof(_val) is "boolean" and items[1] is "alarms"
            replaceVal = if _val then "告警" else "正常"
          else if typeof(_val) is "string" or typeof(_val) is "number"
            replaceVal = _val
          else
            replaceVal = "--"
          html = html.replace("{{" + _index + "-" + items[1] + "}}", replaceVal)
        if _.has(content, "severities")
          for y in [1, 2, 3]
            _val2 = if content?.severities[y - 1]?.value then content.severities[y - 1].value else "--"
            html = html.replace("{{severities" + y + "-value}}", _val2)
      )
      $("#detail-table").append(html)

    groupBy: (items = @items) ->
      @groupByType @allType, items

      typeItems = {}
      for item in items
        typeItems[item.type] ?= []
        typeItems[item.type].push item

      for type in @types.items
        @groupByType type, typeItems[type.type]

      return

    groupByType: (type, items = []) ->
      groups =
        myStart: []
        myProcess: []

        all: []
        approval: []
        reject: []
        progress: []
        cancel: []

      for item in items
        phase = item.phase
        if phase
          if phase.done
            groups[phase.state]?.push item
          else
            groups.progress.push item
        else
          groups.progress.push item

        groups.all.push item

        if item.owner?.id is @loginUser
          groups.myStart.push item

        if item.phase?.nextManager?.id is @loginUser
          groups.myProcess.push item

      type.items = items
      type.groups = groups

    getTaskDatas:(scope) ->
      scope.tasks = []
      @allTasksModels = []
      filter = {}
      filter.user = @$routeParams.user
      filter.project = @$routeParams.project
      filter.createtime = {"$gte":scope.query.startTime,"$lte":scope.query.endTime}
      filter["$or"] = [{"creator.id":scope.$root.user.user},{"nodes.manager.id":scope.$root.user.user},{"$and":[{"phase.nextManager":null},{"phase.progress":null}]}]
      @subscribeMyTasks(scope)
      @taskRecordService.query(filter, null, (err,taskDatas) =>
        if taskDatas
          taskmodels = taskDatas.data
          if taskmodels
            for taskmodel in taskmodels
              @allTasksModels.push taskmodel
              typeModel = _.filter @types.model,(modelItem)->
                return modelItem.type == taskmodel.type
              excutor = ""
              if (_.isEmpty taskmodel.phase.nextManager) && (taskmodel.phase.progress == 1)
                excutor = taskmodel.phase.manager.name
              else if _.isEmpty taskmodel.phase.nextManager
                excutor = null
              else if !_.isEmpty taskmodel.phase.manager
                excutor = taskmodel.phase.manager.name
              else if !_.isEmpty taskmodel.phase.nextManager
                excutor = taskmodel.phase.nextManager.name
              scope.tasks.push({
                _id:taskmodel._id,
                name:taskmodel.name,
                typeName:typeModel[0].name,
                statusName:@getStatusName(taskmodel.phase.progress,taskmodel.phase.state,taskmodel.phase.nextManager),
                currexcutetime:(if _.isEmpty taskmodel.phase.timestamp then null else moment(taskmodel.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
                excutor:excutor
                creator:taskmodel.creator?.name,
                createtime:moment(taskmodel.createtime).format("YYYY-MM-DD HH:mm:ss")
              })
            scope.tasks = scope.tasks.reverse()
      , true)

    getTaskDatas2:(scope)->
        scope.tasks = []
        @allTasksModels = []
        filter = {}
        filter.user = @$routeParams.user
        filter.project = @$routeParams.project
        filter.createtime = {"$gte":scope.query.startTime,"$lte":scope.query.endTime}

        @subscribeMyTasks(scope)
        @commonService.loadProjectModelByService 'tasks', filter, '_id user project type process name creator task phase nodes createtime', (err, taskmodels) =>
          if taskmodels
            for taskmodel in taskmodels
              @allTasksModels.push taskmodel
              typeModel = _.filter @types.model,(modelItem)->
                return modelItem.type == taskmodel.type
              excutor = ""
              if (_.isEmpty taskmodel.phase.nextManager) && (taskmodel.phase.progress == 1)
                excutor = taskmodel.phase.manager.name
              else if _.isEmpty taskmodel.phase.nextManager
                excutor = null
              else if !_.isEmpty taskmodel.phase.manager
                excutor = taskmodel.phase.manager.name
              else if !_.isEmpty taskmodel.phase.nextManager
                excutor = taskmodel.phase.nextManager.name
              scope.tasks.push {
                _id:taskmodel._id,
                name:taskmodel.name,
                typeName:typeModel[0].name,
                statusName:@getStatusName(taskmodel.phase.progress,taskmodel.phase.state,taskmodel.phase.nextManager),
                currexcutetime:(if _.isEmpty taskmodel.phase.timestamp then null else moment(taskmodel.phase.timestamp).format("YYYY-MM-DD HH:mm:ss")),
                excutor:excutor
                creator:taskmodel.creator?.name,
                createtime:moment(taskmodel.createtime).format("YYYY-MM-DD HH:mm:ss")
              }
#            scope.tasks = _.sortBy scope.tasks,(taskItem)->
#              return taskItem.statusName+taskItem.createtime
            scope.tasks = scope.tasks.reverse()
        ,true

    acceptNode: (scope,node, callback) =>
      schema = @taskService.url
      url = @taskService.replaceUrlParam schema, @current, true
#      url = url.substring(url.indexOf("/model"))
      url += "/#{node.node}/accept"

      user = scope.$root.user
      data =
        _id: scope.current._id
        data:
          node: node.node
          manager:
            id: user.user
            name: user.name

      # update node to server
      @taskService.postData url, data, (err, result) =>
#        @addItem result
#
#        @display err, "流程节点[#{data.node}]被[#{user.name}]接收成功"
        callback? err, result

    updateNode: (scope,node, action, callback) ->
      schema = @taskService.url
      url = @taskService.replaceUrlParam schema, @current, true
      url += "/#{node.node}"

#      @updateNodeTemplates node

      user = scope.$root.user
      phase =
        _id: node._id
        node: node.node
        parameters: node.parameters
        contents: node.contents

        state: action
        timestamp: new Date
        manager:
          id: user.user
          name: user.name

      if action is 'forward'
        phase.forwarder = node.forwarder

      data =
        _id: @current._id
        data: phase

      # update node to server
      @taskService.postData url, data, (err, result) =>
#        @display err, "流程节点[#{node.node}]提交成功"
        callback? err, result
    getTaskMaxNo: (callback)->
      aggregateCons = []
      matchObj = {}
      groupObj = {}

      filter = @$routeParams
      matchObj.$match = filter
      groupObj.$group = {
        _id:
          user:"$user"
          project:"$project"

        maxtaskno:
          $max:"$name"
      }
      aggregateCons.push matchObj
      aggregateCons.push groupObj

      @commonService.reportingService.aggregateTasks {filter:@$routeParams,pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        currDate = moment().format("YYYYMMDD")
        if records && records.length > 0
          maxNO = records[0].maxtaskno.substring(0,8)

          orderid = records[0].maxtaskno.substring(8,10)
          if maxNO == currDate
            tmporder = (parseInt(orderid)+1).toString()
            if tmporder.length < 2
              tmporder = "0"+ tmporder
            currDate = currDate + tmporder
            callback? currDate
          else
            currDate = currDate + "01"
            callback? currDate
        else
          currDate = currDate + "01"
          callback? currDate

    subscribeStationSignlVal:(scope)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups1"
        signal:"a-phase--output-load-percentage"

      @equipSubscription["center-qianjiang"+"ups1"+"a-phase--output-load-percentage"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups1"+"a-phase--output-load-percentage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[0].equips[0].value[0].value < d.message.value
          scope.checkContent[0].equips[0].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups1"
        signal:"b-phase--output-load-percentage"

      @equipSubscription["center-qianjiang"+"ups1"+"b-phase--output-load-percentage"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups1"+"b-phase--output-load-percentage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[0].equips[0].value[0].value < d.message.value
          scope.checkContent[0].equips[0].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups1"
        signal:"c-phase--output-load-percentage"

      @equipSubscription["center-qianjiang"+"ups1"+"c-phase--output-load-percentage"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups1"+"c-phase--output-load-percentage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[0].equips[0].value[0].value < d.message.value
          scope.checkContent[0].equips[0].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups2"
        signal:"a-phase--output-load-percentage"

      @equipSubscription["center-qianjiang"+"ups2"+"a-phase--output-load-percentage"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups2"+"a-phase--output-load-percentage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[0].equips[1].value[0].value < d.message.value
          scope.checkContent[0].equips[1].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups2"
        signal:"b-phase--output-load-percentage"

      @equipSubscription["center-qianjiang"+"ups2"+"b-phase--output-load-percentage"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups2"+"b-phase--output-load-percentage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[0].equips[1].value[0].value < d.message.value
          scope.checkContent[0].equips[1].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups2"
        signal:"c-phase--output-load-percentage"

      @equipSubscription["center-qianjiang"+"ups2"+"c-phase--output-load-percentage"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups2"+"c-phase--output-load-percentage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[0].equips[1].value[0].value < d.message.value
          scope.checkContent[0].equips[1].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups1"
        signal:"communication-status"

      @equipSubscription["center-qianjiang"+"ups1"+"communication-status"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups1"+"communication-status"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        scope.checkContent[0].equips[0].value[1].value = @getCommounicationName(d.message.value)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "ups2"
        signal:"communication-status"

      @equipSubscription["center-qianjiang"+"ups2"+"communication-status"]?.dispose()
      @equipSubscription["center-qianjiang"+"ups2"+"communication-status"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        scope.checkContent[0].equips[1].value[1].value = @getCommounicationName(d.message.value)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "th1"
        signal:"temperature"

      @equipSubscription["center-qianjiang"+"th1"+"temperature"]?.dispose()
      @equipSubscription["center-qianjiang"+"th1"+"temperature"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        scope.checkContent[1].equips[0].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "th1"
        signal:"humidity"

      @equipSubscription["center-qianjiang"+"th1"+"humidity"]?.dispose()
      @equipSubscription["center-qianjiang"+"th1"+"humidity"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        scope.checkContent[1].equips[0].value[1].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "battery-room"
        equipment: "th16"
        signal:"temperature"

      @equipSubscription["battery-room"+"th16"+"temperature"]?.dispose()
      @equipSubscription["battery-room"+"th16"+"temperature"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        scope.checkContent[1].equips[1].value[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "battery-room"
        equipment: "th16"
        signal:"humidity"

      @equipSubscription["battery-room"+"th16"+"humidity"]?.dispose()
      @equipSubscription["battery-room"+"th16"+"humidity"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        scope.checkContent[1].equips[1].value[1].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "meter4"
        signal:"phase-a-voltage"

      @equipSubscription["center-qianjiang"+"meter4"+"phase-a-voltage"]?.dispose()
      @equipSubscription["center-qianjiang"+"meter4"+"phase-a-voltage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[2].equips[0].value < d.message.value
          scope.checkContent[2].equips[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "meter4"
        signal:"phase-b-voltage"

      @equipSubscription["center-qianjiang"+"meter4"+"phase-b-voltage"]?.dispose()
      @equipSubscription["center-qianjiang"+"meter4"+"phase-b-voltage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[2].equips[0].value < d.message.value
          scope.checkContent[2].equips[0].value = d.message.value.toFixed(2)
      ,true

      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: "center-qianjiang"
        equipment: "meter4"
        signal:"phase-c-voltage"

      @equipSubscription["center-qianjiang"+"meter4"+"phase-c-voltage"]?.dispose()
      @equipSubscription["center-qianjiang"+"meter4"+"phase-c-voltage"] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        return if err
        if scope.checkContent[2].equips[0].value < d.message.value
          scope.checkContent[2].equips[0].value = d.message.value.toFixed(2)
      ,true

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

    getCommounicationName:(status)->
      if status == 0
        return "正常"
      else
        return "异常"

    resize: (scope)->

    dispose: (scope)->
      @timeSubcrib?.dispose()
      _.mapObject @equipSubscription,(item)->
      item?.dispose()

  exports =
    ComponentMaintasksDirective: ComponentMaintasksDirective