###
* File: comp-defectsetting-directive
* User: James
* Date: 2019/11/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CompDefectsettingDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "comp-defectsetting"
      super $timeout, $window, $compile, $routeParams, commonService

      @groupService = commonService.modelEngine.modelManager.getService("groups")
      @processService = commonService.modelEngine.modelManager.getService("processes")
      @notificationrulesService = commonService.modelEngine.modelManager.getService("notificationrules")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 全局信息 - 渲染数据
      scope.processType = "defect"
      scope.allStationFlag = false
      scope.allEquipTypeFlag = false
      scope.allEventTypeFlag = false

      scope.allStationCheckFlags ={}
      scope.allEquipTypeCheckFlags ={}
      scope.allEventTypeCheckFlags ={}

      scope.current=defaultVal = {
        visible: true
        enable: true
      }
      scope.textinfo = {
        btns: [{title:"删除",show:true},{title:"取消",show:false},{title:"保存",show:true},{title:"新增",show:true}]
      }
      scope.notificationRule = {
        allEquipmentTypes: true
        allEquipments: true
        eventPhases: ["start"]
        allEventSeverities: true
        allEventTypes: true
        allStations: true
      }
      scope.groupInfo = { process: "", name: "", desc:"",engineers: [], addUser: "" }
      scope.editState = true
      scope.selectNodeId = null
      scope.memberList = []
      scope.notificationObjs = {
        notification :""
        name: "工作流-故障工单"
        title: scope.processType
        content: "故障工单消息"
        contentType: "template"
        type: "workflow"
        delay: 0
        enable: true
        events: []
        index: 0
        phase: "start"
        priority: 0
        repeatPeriod: 0
        repeatTimes: 0
        ruleType: "complex"
        timeout: 10
        users: ["_all"]
        visible: true
        rule:scope.notificationRule
      }
      #获取设备类型，初始化设备类型选项值
      tmpEquipTypes = _.filter scope.project.dictionary.equipmenttypes.items,(item)->
        return item.model.type.charAt(0) isnt "_"
      scope.equipmentTypes = _.sortBy tmpEquipTypes,(item)->
        scope.allEquipTypeCheckFlags[item.model.type] = false
        return item.model.index

      scope.eventTypeList = _.sortBy scope.project.dictionary.eventtypes.items,(item)->
        scope.allEventTypeCheckFlags[item.model.type] = false
        return item.model.index

      _.each scope.project.stations.items,(item)->
        if item.model.station.charAt(0) isnt "_"
          scope.allStationCheckFlags[item.model.station] = false

      roots = _.filter scope.project.stations.items,(val,key)=>
        return (val.model.parent == "") && (val.model.station.charAt(0) isnt "_")

      @htmlstr = ""
      for rootItem in roots
        @htmlstr += '<div class="repeat-label"><md-checkbox ng-model="allStationCheckFlags[\'' + rootItem.model.station + '\']"  id="station-' + rootItem.model.station + '"  ng-disabled="allStationFlag" with-gap=false filled-in=true label="' + rootItem.model.name + '"></md-checkbox>'
        @recurStation rootItem,@htmlstr
      @htmlstr += "</div>"

      elem = @$compile(@htmlstr)(scope)

      $('#recurestationid').append elem
      scope.btnClick = (type) =>
        if type is 2
          #保存工作计划信息
          if scope.groupInfo.process is "" || scope.groupInfo.name is ""
            M.toast({ html: '温馨提示：流程ID/流程名称不可为空！！' })
            return

          if scope.editState
            tmpProcess = _.find(@allProcesses, (d) => d.process is scope.groupInfo.process)
            if tmpProcess
              @display "温馨提示：该ID已被占用！！"
              return

          if scope.memberList.length < 1
            @display "温馨提示：请选择班组成员！"
            return;

          @saveProcess(scope)
        else if type is 3
          #新增模式！！ 置空表单数据
          scope.selectNodeId = null
          scope.memberList = []
          scope.editState = true
          @resetSelectModelDatas(scope)

          @getUniqueName scope.processList, "defect", 'process', 1
          scope.groupInfo = { process: (@getUniqueName scope.processList, "defect", 'process', 1), name: (@getUniqueName scope.processList, "故障工单", 'name', 1), desc:"",engineers: [], addUser: "" }

        else if type is 0
          if scope.groupInfo.process != ""
            #删除模式
            @current = {
              process: scope.groupInfo.process,
              name: scope.groupInfo.name,
              desc: scope.groupInfo.desc,

            }
            @current = _.extend(@current, scope.project.getIds())
            @deleteProcess(scope)
          else
            M.toast({html:"不可删除空id的表单！！"})


      # 班组成员组 的 "新增" / "删除"
      scope.updateMember = (index) =>
        if typeof(index) is "number"
          scope.memberList = _.filter(scope.memberList, (d) => d.id isnt scope.memberList[index].id)
          scope.showAddSelect = false
          scope.$applyAsync();
        else
          hasUser = _.find(scope.memberList, (d) => d.id is index)
          addUserObj = _.find(scope.userList, (d) => d.value is index)
          if !hasUser and addUserObj
            scope.memberList.push({ name: addUserObj.name, title: "employee", id: addUserObj.value})
            scope.groupInfo.addUser = ""
            scope.$applyAsync();
          else
            M.toast({ html: if index == "" then "不可选择空用户！！" else '请选择一个不在班组内的用户！！' })

      scope.selectProcess = (index, item) =>
        scope.editState = false
        if scope.selectNodeId isnt index
          scope.selectNodeId = index
          @current = _.find @allProcesses,(processItem)->
            return processItem._id == item._id

          scope.selectNodeId = index
          scope.groupInfo = @current
          scope.memberList = if item.engineers then item.engineers else []

          filter = scope.project.getIds()
          filter.notification = @current.process
          @notificationrulesService.query filter,null,(err,notifDatas)=>
            @resetSelectModelDatas(scope)
            if !_.isEmpty notifDatas
              if notifDatas.rule.allStations
                scope.allStationFlag = true
                scope.allStationCheckFlags = _.mapObject scope.allStationCheckFlags,(val,key)->
                  val = true
              else
                if notifDatas.rule.stations?.length > 0
                  for stationItem in  notifDatas.rule.stations
                    scope.allStationCheckFlags[stationItem] = true

              if notifDatas.rule.allEquipmentTypes
                scope.allEquipTypeFlag = true
                scope.allEquipTypeCheckFlags = _.mapObject scope.allEquipTypeCheckFlags,(val,key)->
                  val = true
              else
                if notifDatas.rule.equipmentTypes?.length > 0
                  for equipTypeItem in  notifDatas.rule.equipmentTypes
                    scope.allEquipTypeCheckFlags[equipTypeItem] = true

              if notifDatas.rule.allEventTypes
                scope.allEventTypeFlag = true
                scope.allEventTypeCheckFlags = _.mapObject scope.allEventTypeCheckFlags,(val,key)->
                  val = true
              else
                if notifDatas.rule.eventTypes?.length > 0
                  for eventTypeItem in  notifDatas.rule.eventTypes
                    scope.allEventTypeCheckFlags[eventTypeItem] = true
          ,true
          scope.$applyAsync();


      scope.selectAllstations = ()->
        if scope.allStationFlag
          scope.allStationCheckFlags = _.mapObject scope.allStationCheckFlags,(val,key)->
            val = true
        else
          scope.allStationCheckFlags = _.mapObject scope.allStationCheckFlags,(val,key)->
            val = false
        scope.$applyAsync();

      scope.selectAllequiptypes = ()->
        if scope.allEquipTypeFlag
          scope.allEquipTypeCheckFlags = _.mapObject scope.allEquipTypeCheckFlags,(val,key)->
            val = true
        else
          scope.allEquipTypeCheckFlags = _.mapObject scope.allEquipTypeCheckFlags,(val,key)->
            val = false
        scope.$applyAsync();

      scope.selectAlleventeypes = ()->
        if scope.allEventTypeFlag
          scope.allEventTypeCheckFlags = _.mapObject scope.allEventTypeCheckFlags,(val,key)->
            val = true
        else
          scope.allEventTypeCheckFlags = _.mapObject scope.allEventTypeCheckFlags,(val,key)->
            val = false
        scope.$applyAsync();

      @loadGroup(scope,(groups) =>
        if groups
          userOption = []
          for groupItem in groups
            _.map groupItem.engineers, (d) ->
              userOption.push { name:d.name, value:d.name }
          scope.userList = userOption
          scope.$applyAsync();
      );

      @loadProcess scope,(process)=>


    saveProcess:(scope)=>
      if scope.allStationFlag
        delete scope.notificationRule["stations"]
        scope.notificationRule["allStations"] = true
      else
        delete scope.notificationRule["allStations"]
        scope.notificationRule["stations"] = []
        _.mapObject scope.allStationCheckFlags,(val,key)=>
          if val
            scope.notificationRule["stations"].push key

      if scope.allEquipTypeFlag
        delete scope.notificationRule["equipmentTypes"]
        scope.notificationRule["allEquipmentTypes"] = true
      else
        delete scope.notificationRule["allEquipmentTypes"]
        scope.notificationRule["equipmentTypes"] = []
        _.mapObject scope.allEquipTypeCheckFlags,(val,key)=>
          if val
            scope.notificationRule["equipmentTypes"].push key

      if scope.allEventTypeFlag
        delete scope.notificationRule["eventTypes"]
        scope.notificationRule["allEventTypes"] = true
      else
        delete scope.notificationRule["allEventTypes"]
        scope.notificationRule["eventTypes"] = []
        _.mapObject scope.allEventTypeCheckFlags,(val,key)=>
          if val
            scope.notificationRule["eventTypes"].push key

      @createProcessTemplate scope,(err,processData)=>
        if err
          @display "错误提示："+err
          return
        notificationObj = scope.notificationObjs
        notificationObj = _.extend scope.project.getIds(),scope.notificationObjs

        filter = scope.project.getIds()
        filter.notification = processData.process
        @notificationrulesService.query filter,null,(err,notificationDatas)=>
          if !err
            if notificationDatas.length > 0
              notificationObj = notificationDatas[0]

            notificationObj.notification = scope.groupInfo.process
            notificationObj.title = scope.processType + "/" +scope.groupInfo.process
            notificationObj.name = scope.groupInfo.name
            notificationObj.rule = scope.notificationRule
            @notificationrulesService.save notificationObj,(err,processData)=>
              if err
                @display "温馨提示：" + err
              else
                @display "温馨提示：操作成功！"
              @loadProcess scope,(process)=>
        ,true
    resetSelectModelDatas:(scope)->
      scope.allStationFlag = false
      scope.allEquipTypeFlag = false
      scope.allEventTypeFlag = false

      scope.allStationCheckFlags = _.mapObject scope.allStationCheckFlags,(val,key)->
          val = false
      scope.allEquipTypeCheckFlags = _.mapObject scope.allEquipTypeCheckFlags,(val,key)->
        val = false
      scope.allEventTypeCheckFlags = _.mapObject scope.allEventTypeCheckFlags,(val,key)->
        val = false

    deleteProcess:(scope)=>
      @processService.remove @current,(err,processData)=>
        if err
          @display err,processData
        else
          # 置空
          scope.selectNodeId = null
          scope.memberList = []
          scope.editState = true
          scope.selectedEquipSignalList = {}
          scope.groupInfo = { process: "", name: "", desc:"",engineers: [], addUser: "" }
          scope.processList = _.filter(scope.processList, (d) => d.process != processData[0].process)
          scope.$applyAsync()
          @display "温馨提示：操作成功！"

    loadGroup: (scope,callback)=>
      filter = {}
      filter.user = @$routeParams.user
      filter.project = @$routeParams.project

      @groupService.query filter, 'group name managerName parent engineers', (err, groupModels) =>
        if groupModels
          scope.allGroups = groupModels
        callback(groupModels)
      ,true

    getUniqueName: (items, prefix, property, index = 1) ->
      name = "#{prefix}-#{index}"
      if items
        for item in items
          if item[property] is name
            return @getUniqueName items, prefix, property, index + 1
      name

    loadProcess:(scope,callback) =>
      filter = scope.project.getIds()
      filter.type = scope.processType
      @processService.query filter, null, (err, processModels) =>
        if processModels
          @allProcesses = processModels
          scope.processList = processModels
        callback(processModels)
      ,true

    #创建流程模板
    createProcessTemplate:(scope,callback)=>
      filter = scope.project.getIds()
      filter.process = scope.groupInfo.process
      @processService.query filter, null, (err, procesDatas) =>
        if !(_.isEmpty procesDatas)
          procesDatas.nodes[0].contents[0].content = JSON.stringify({content:"",handle_details:[],attachments:[]})
          procesDatas.name = scope.groupInfo.name
          procesDatas.desc = scope.groupInfo.desc
          @processService.save procesDatas,(err,processData)=>
            callback? err,processData
        else
          nodeObj = {
            name:"流程节点1"
            node:"node-1"
            timeout:0
            actions:{
              approval:true
              reject:true
              forward:true
              save:true
            }
            contents:[{type:"json",content:JSON.stringify({content:"",handle_details:[],attachments:[]})}]

          }
          templateObj = {
            name:scope.groupInfo.name
            process:scope.groupInfo.process
            desc:scope.groupInfo.desc
            trigger:"event"
            type:scope.processType
            enable:true
            visible:true
            cancleable:true
            priority:null
            nodes:[]
          }
          templateObj.nodes.push nodeObj
          templateObj = _.extend templateObj,scope.project.getIds()
          @processService.save templateObj,(err,processData)=>
            callback? err,processData
      ,true

    recurStation:(restation)=>
      if restation.stations.length > 0
        @htmlstr += '<div style="margin-left: 30px;margin-top: .5rem">'
        for stationItem in restation.stations
          @htmlstr += '<div>'
          @htmlstr += '<md-checkbox ng-model="allStationCheckFlags[\'' + stationItem.model.station + '\']"  id="station-' + stationItem.model.station + '" ng-change="changeStations(\''+ stationItem.model.station + '\')" ng-disabled="allStationFlag" with-gap=false filled-in=true label="' + stationItem.model.name + '"></md-checkbox>'
          @recurStation(stationItem)
        @htmlstr += "</div>"
      else
        @htmlstr += "</div>"
        return

    getUniqueName: (items, prefix, property, index = 1) ->
      name = "#{prefix}-#{index}"
      if items
        for item in items
          if item[property] is name
            return @getUniqueName items, prefix, property, index + 1
      name

    resize: (scope)->

    dispose: (scope)->
      $('.gldp-default').remove()
      scope.checkEquipsSubscription?.dispose()


  exports =
    CompDefectsettingDirective: CompDefectsettingDirective