###
* File: comp-workplan-directive
* User: James
* Date: 2019/11/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CompWorkplanDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "comp-workplan"
      super $timeout, $window, $compile, $routeParams, commonService
      @allUsers = []

      @allShifts  = []
      @groupService = commonService.modelEngine.modelManager.getService("groups")
      @shiftService = commonService.modelEngine.modelManager.getService("shifts")
      @processService = commonService.modelEngine.modelManager.getService("processes")
    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @init(scope)
      scope.allGroups = []
      scope.workcontentIndex = null
      scope.selectedWorkconItem = null
      scope.workcontentNode = @getComponentPath('images/startnode.png')
      scope.workcontentEndNode = @getComponentPath('images/endnode.png')
      scope.workRoute = []
      # 默认值
      scope.current=defaultVal = {
#        trigger: 'everyday'
        weekdays:
          Mon: true
          Tue: true
          Wed: true
          Thu: true
          Fri: true
          Sta: true
          Sun: true
        jobs: [{job: "job-1", name: "任务-1", crons: [{type: "on"}],tasks: [{type: "", process: ""}]}]
        month: moment().add("months",1).format("YYYY-MM")
        visible: true
        enable: true
      }
      scope.current.group = ""
      scope.weekdays = [
        {name: '周一', key: 'Mon',chkstatus:true}
        {name: '周二', key: 'Tue',chkstatus:true}
        {name: '周三', key: 'Wed',chkstatus:true}
        {name: '周四', key: 'Thu',chkstatus:true}
        {name: '周五', key: 'Fri',chkstatus:true}
        {name: '周六', key: 'Sta',chkstatus:true}
        {name: '周日', key: 'Sun',chkstatus:true}
      ]

      # 全局信息 - 渲染数据
      scope.textinfo = {
        btns: [{title:"删除",show:true,icon:"delete_forever"},{title:"取消",show:false,icon:"cancel"},{title:"保存",show:true,icon:"save"},{title:"新增",show:true,icon:"note_add"}]
      }
      scope.editState = true
      today = moment().format("YYYY-MM-DD")
      scope.selectNodeId = null
      scope.selectSignalNodeId = null
      scope.memberList = []
      scope.groupInfo = { shift: "", name: "", onTime:moment().format("HH:mm"),offTime:"",startTime:moment().format("YYYY-MM-DD"), endTime:moment().add(1,"years").format("YYYY-MM-DD"),desc:"",engineers: [], addUser: "" }
      widths = [0, 0]
      # datapicker组件配置 初始化
      setGlDatePicker = (element,value) ->
        return if not value
        setTimeout =>
          gl = $(element).glDatePicker({
            dowNames:["日","一","二","三","四","五","六"],
            monthNames:["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"],
            selectedDate: moment(value).toDate()
            onClick:(target,cell,date,data) =>
              target.val(moment(date).format("YYYY-MM-DD")).trigger("change")
          })
        ,500

      setGlDatePicker($('.datepickerInput')[0], today)
      setGlDatePicker($('.datepickerInput')[1], today)

      scope.setDrop = (type) =>
        if type is 0
          resize = $($('.datepickerInput')[0]).offset()
          widths[0] = $($('.datepickerInput')[0]).outerWidth() if widths[0] is 0
          $($('.gldp-default')[0]).css("left": resize.left + "px","width": (widths[0]  + 5)+ "px", "top": (resize.top + 40) + "px", "position": "absolute", "text-align": "center")
        else
          resize = $($('.datepickerInput')[1]).offset()
          widths[1] = $($('.datepickerInput')[1]).outerWidth() if widths[1] is 0
          $($('.gldp-default')[1]).css("left": resize.left + "px","width": (widths[1]  + 5)+ "px", "top": (resize.top + 40) + "px", "position": "absolute", "text-align": "center")
        $('.core').css("display": "inline-block");

      # button - 点击事件
      # 工作计划 的 "新增" / "保存" / "删除"
      checkTime = (startTime, endTime) =>
        return moment(startTime).valueOf() > moment(endTime).valueOf()
      formatToStr = (time) ->
        arr = [time.getHours(), time.getMinutes(), "00"]
        arr = _.map(arr, (d) ->
          return "00" if d is 0
          return d
        )
        return arr.join(":")
      scope.btnClick = (type) =>
        if type is 2
          #保存工作计划信息

          if _.isEmpty scope.groupInfo.shift
            @display "温馨提示：请输入不超过20数字字符、字母或-！"
            return
          if _.isEmpty scope.groupInfo.name
            @display "温馨提示：请输入工班名称！"
            return

          tmpName = scope.groupInfo.name.replace(/\s+/g, "")
          if  (!(tmpName.length > 0 ) || tmpName.length > 20)
            @display "温馨提示：请输入小于20个字的工班名称！"
            return

          if !scope.editState
            if @current.creator.id isnt scope.$root.user.user
              @display "温馨提示：创建该任务的人才有权限修改！！"
              return
          if scope.groupInfo.shift is "" || scope.groupInfo.name is ""
            M.toast({ html: '温馨提示：工班ID/工班名称不可为空！！' })
            return
          #             or checkTime(scope.groupInfo.onTime, scope.groupInfo.offTime)
          if checkTime(scope.groupInfo.startTime, scope.groupInfo.endTime)
            M.toast({ html: '温馨提示：计划开始时间不可晚于计划结束时间！！' })
            return
          #          if checkTime(scope.groupInfo.onTime, scope.groupInfo.offTime)
          #            M.toast({ html: '温馨提示：上班时间不可晚于下班时间！！' })
          #            return

          if scope.editState
            childGroups = _.find(@allShifts, (d) => d.shift is scope.groupInfo.shift)
            if childGroups
              @display "温馨提示：该ID已被占用！！"
              return

          reg = /^((20|21|22|23|[0-1]\d):[0-5]\d)|((20|21|22|23|[0-1]\d):[0-5]\d:[0-5]\d)$/;
          regExp = new RegExp(reg);
          if(!regExp.test(scope.groupInfo.onTime))
            @display "温馨提示：时间不能为空，请查证！"
            return;
          tmpWeekDays = _.filter scope.weekdays,(item)->
              return item.chkstatus
          if !(tmpWeekDays.length > 0)
            @display "温馨提示：周天不能为空，请查证！"
            return;
          if scope.memberList.length < 1
            @display "温馨提示：请选择班组成员！"
            return;

          @current = {
            shift: scope.groupInfo.shift,
            name: scope.groupInfo.name.replace(/\s+/g, ""),
            desc: scope.groupInfo.desc,
            engineers: scope.memberList,
            startTime: scope.groupInfo.startTime,
            endTime: scope.groupInfo.endTime,
            onTime: scope.groupInfo.onTime
          }

          # 根据@allShifts 判断是否是编辑模式
          editObj = _.find(@allShifts, (d) => d.shift is @current.shift)
          if editObj
            @current[x] = editObj[x] for x in ["_index", "_id", "project", "user"]
          else
            @current = _.extend(scope.project.getIds(), @current)
          @current = _.extend(@current, defaultVal)

          @saveShift(scope)
        else if type is 3
          #新增模式！！ 置空表单数据
          scope.selectNodeId = null
          scope.memberList = []
          scope.workRoute = []
          scope.editState = true
          scope.weekdays = [
            {name: '周一', key: 'Mon',chkstatus:true}
            {name: '周二', key: 'Tue',chkstatus:true}
            {name: '周三', key: 'Wed',chkstatus:true}
            {name: '周四', key: 'Thu',chkstatus:true}
            {name: '周五', key: 'Fri',chkstatus:true}
            {name: '周六', key: 'Sta',chkstatus:true}
            {name: '周日', key: 'Sun',chkstatus:true}
          ]
#          @getUniqueName scope.shiftList, "plan", 'shift', 1
          scope.selectedEquipSignalList = []
          scope.groupInfo = { shift: (@getUniqueName scope.shiftList, "plan", 'shift', 1), name: (@getUniqueName scope.shiftList, "巡检工单", 'name', 1), onTime:moment().format("HH:mm"),offTime:"",startTime:moment().format("YYYY-MM-DD"), endTime:moment().add(1,"years").format("YYYY-MM-DD"),desc:"",engineers: [], addUser: "" }

        else if type is 0
          if scope.groupInfo.shift != ""
#删除模式
            @current = {
              shift: scope.groupInfo.shift,
              name: scope.groupInfo.name,
              desc: scope.groupInfo.desc,
              engineers: scope.memberList,
              startTime: scope.groupInfo.startTime,
              endTime: scope.groupInfo.endTime,
              onTime: moment(scope.groupInfo.onTime).format("HH:mm"),
              offTime: moment(scope.groupInfo.offTime).format("HH:mm")
            }
            @current = _.extend(@current, scope.project.getIds())
            scope.prompt '温馨提示','是否确定删除工班 ' + scope.groupInfo.name + "?",(ok, comment)=>
              return if not ok
              @deleteShift(scope)
          else
            M.toast({html:"不可删除空id的表单！！"})

      @loadShift(scope,(shifts)=>
        @warpShifts(scope,shifts)
      )

      scope.selectShift = (index, item) =>
        scope.editState = false
        if scope.selectNodeId isnt index
          scope.selectedWorkconItem = null
          scope.workcontentIndex = null
          scope.workRoute = []
          scope.selectNodeId = index
          @current = _.find @allShifts,(shiftItem)->
            return shiftItem._id == item._id
          @current.startTime = moment(@current.startTime ).format("YYYY-MM-DD")
          @current.endTime = moment(@current.endTime ).format("YYYY-MM-DD")
          @current.creator = item.creator
          scope.selectNodeId = index
          scope.groupInfo = @current
          scope.memberList = if item.engineers then item.engineers else []
          _.mapObject item.weekdays,(val,key)->
            weekdaysObj = _.find scope.weekdays,{key:key}
            weekdaysObj?.chkstatus = val

          filter = item.jobs[0].tasks[0]
          delete filter["actionType"]
          _.extend filter,scope.project.getIds()
          @processService.query filter,null,(err,processDatas)=>
            if processDatas
              if angular.isString processDatas.nodes[0].contents[0].content
                workContent = JSON.parse processDatas.nodes[0].contents[0].content
              else
                workContent = processDatas.nodes[0].contents[0].content
              if !_.isEmpty workContent.content
                if workContent.content.length > 0
                  scope.workcontentIndex = 0
                  scope.selectedWorkconItem = workContent.content[0]
                  workcontentGroup = _.groupBy workContent.content,(item)->
                    return item.stationName + "." + item.equipName

                  _.mapObject workcontentGroup,(val,key)=>
                    titleContent = "\n "
                    for valItem in val
                      titleContent += valItem.signalName + "\n"
                    scope.workRoute.push {equipId:key,lists:titleContent,imgurl:scope.workcontentNode}
                  scope.workRoute[scope.workRoute.length - 1].imgurl = scope.workcontentEndNode
              scope.selectedEquipSignalList = workContent.content

          scope.$applyAsync();

      scope.selectWorkcontent = (index, item) =>
        if scope.workcontentIndex isnt index
          scope.workcontentIndex = index
          scope.selectedWorkconItem = item


      scope.selectEquipSignal = (index, item) =>
        if scope.selectSignalNodeId isnt index
          scope.selectSignalNodeId = index


          scope.$applyAsync();
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

      scope.resetdUserList = ()=>
        scope.memberList = []
        scope.groupInfo.addUser = null
        selectGgroup =  _.find scope.allGroups,{group:scope.current.group}
        if selectGgroup
          userOption = _.map(selectGgroup.engineers, (d) -> { name:d.name, value:d.name })
          #        scope.textinfo.form[0][0].option = userOption
          scope.userList = userOption
        else
          scope.userList = null
        scope.$applyAsync()

      scope.saveWorkItems = ()=>
        tmpEquipSignals = _.filter scope.equipSignalList,(item)->
          return item.chkstatus
        checkpointno = 0
        for tmpEquipSignalsItem in tmpEquipSignals
          checkpointno++
          tmpEquipSignalsItem.orderno = checkpointno


        scope.selectedEquipSignalList = tmpEquipSignals
        if !_.isEmpty scope.selectedEquipSignalList
          if scope.selectedEquipSignalList.length > 0
            scope.workcontentIndex = 0
            scope.selectedWorkconItem = scope.selectedEquipSignalList[0]

            workcontentGroup = _.groupBy scope.selectedEquipSignalList,(item)->
              return item.stationName + "." + item.equipName

            scope.workRoute = []
            _.mapObject workcontentGroup,(val,key)=>
              titleContent = "\n "
              for valItem in val
                titleContent += valItem.signalName + "\n"
              scope.workRoute.push {equipId:key,lists:titleContent,imgurl:scope.workcontentNode}
            scope.workRoute[scope.workRoute.length - 1].imgurl = scope.workcontentEndNode
      scope.contentMoveup = ()=>
        if _.isEmpty scope.selectedWorkconItem
          @display "温馨提示：请选择工作内容记录！"
          return

        if scope.workcontentIndex != 0
          lastIndex = scope.workcontentIndex - 1
          lastItem = scope.selectedEquipSignalList[lastIndex]
          scope.selectedEquipSignalList[lastIndex] = scope.selectedWorkconItem
          scope.selectedEquipSignalList[scope.workcontentIndex] = lastItem
          scope.workcontentIndex = lastIndex
          for k,v of scope.selectedEquipSignalList
            if k != "_indexOf"
              v.orderno = parseInt(k) + 1

          workcontentGroup = _.groupBy scope.selectedEquipSignalList,(item)->
            return item.stationName + "." + item.equipName

          scope.workRoute = []
          _.mapObject workcontentGroup,(val,key)=>
            titleContent = "\n "
            for valItem in val
              titleContent += valItem.signalName + "\n"
            scope.workRoute.push {equipId:key,lists:titleContent,imgurl:scope.workcontentNode}
          scope.workRoute[scope.workRoute.length - 1].imgurl = scope.workcontentEndNode
          scope.$applyAsync()


      scope.contentMovedown = ()=>
        if _.isEmpty scope.selectedWorkconItem
          @display "温馨提示：请选择工作内容记录！"
          return

        endIndex = scope.selectedEquipSignalList.length - 1
        if scope.workcontentIndex != endIndex
          nextIndex = scope.workcontentIndex + 1
          nextItem = scope.selectedEquipSignalList[nextIndex]
          scope.selectedEquipSignalList[nextIndex] = scope.selectedWorkconItem
          scope.selectedEquipSignalList[scope.workcontentIndex] = nextItem
          scope.workcontentIndex = nextIndex
          for k,v of scope.selectedEquipSignalList
            if k != "_indexOf"
              v.orderno = parseInt(k) + 1

          workcontentGroup = _.groupBy scope.selectedEquipSignalList,(item)->
            return item.stationName + "." + item.equipName

          scope.workRoute = []
          _.mapObject workcontentGroup,(val,key)=>
            titleContent = "\n "
            for valItem in val
              titleContent += valItem.signalName + "\n"
            scope.workRoute.push {equipId:key,lists:titleContent,imgurl:scope.workcontentNode}
          scope.workRoute[scope.workRoute.length - 1].imgurl = scope.workcontentEndNode
          scope.$applyAsync()

      scope.checkEquipsSubscription?.dispose()
      scope.checkEquipsSubscription = @commonService.subscribeEventBus 'checkEquips',(msg)=>
        tmpequips = _.filter msg.message,(item)=>
          item.level == 'equipment'

        scope.selectedEquips = []
        scope.equipSignalList = []
        scope.allSelectStatus = false
        projectIds = scope.project.getIds()
        for equip in tmpequips
          equipKey = projectIds.user + "_" + projectIds.project + "_" + equip.station + "_" + equip.id
          equipObj = _.find scope.allEquips,{key:equipKey}
          if equipObj
            scope.selectedEquips.push equipObj
            for signalItme in equipObj.points.items
              scope.equipSignalList.push {id:equipObj.model.station + "." + equipObj.model.equipment + "." + signalItme.model.signal,station:equipObj.model.station,stationName:equipObj.model.stationName,equipment:equipObj.model.equipment,equipName:equipObj.model.name,signal:signalItme.model.point,signalName:signalItme.model.name,chkstatus:false}

        scope.$applyAsync()

      scope.selectAllSignals = ()=>
        if scope.allSelectStatus
          _.each scope.equipSignalList,(item)->
            item.chkstatus = true
        else
          _.each scope.equipSignalList,(item)->
            item.chkstatus = false
        scope.$applyAsync()

      @loadGroup(scope,(groups) =>
        if groups
          userOption = []
          for groupItem in groups
            _.map groupItem.engineers, (d) ->
              userOption.push { name:d.name, value:d.name }
          scope.userList = userOption
          scope.$applyAsync();
      );

# 处理
    warpShifts:(scope,shifts) =>
#      shiftOption = _.sortBy(_.map(shifts, (d) =>
#        return {
#          name:d.name, shift:d.shift,index:d._index,
#          onTime: if d.onTime then new Date(moment("2019-01-01 " + d.onTime)) else new Date(moment("2019-07-09 00:00:00")),
#          offTime: if d.offTime then new Date(moment("2019-01-01 " + d.offTime)) else new Date(moment("2019-07-09 00:00:00")),
#          startTime: if d.startTime then moment(d.startTime).format("YYYY-MM-DD") else moment().format("YYYY-MM-DD"),
#          endTime: if d.endTime then moment(d.endTime).format("YYYY-MM-DD") else moment().format("YYYY-MM-DD"),
#          desc:d.desc,
#          engineers: d.engineers,
#          addUser: "",
#          _id:d._id
#        }
#      ), (shiftOptionItem) -> shiftOptionItem.index)
      shiftOption = _.sortBy shifts,(item)->
        return -item._index
      scope.shiftList = shiftOption
      scope.$applyAsync();

    saveShift:(scope)=>
      if (_.isEmpty scope.selectedEquipSignalList) || (scope.selectedEquipSignalList?.length < 1)
        @display "温馨提示：工作内容不能为空，请查证！"
        return

      @createProcessTemplate scope,(err,processData)=>
        if err
          @display "错误提示："+err
          return
        scope.editState = false
        for dayItem in scope.weekdays
          @current.weekdays[dayItem.key] = dayItem.chkstatus
        @current.onTime = scope.groupInfo.onTime
        @current.jobs[0].tasks[0] = {type:processData.type,process:processData.process,actionType:"process"}
        @shiftService.save @current,(err,shiftData)=>
          if err
            @display err,shiftData
          else
#          shiftData.offTime = if shiftData.offTime then new Date(moment("2019-01-01 " + shiftData.offTime, "YYYY-MM-DD HH:MM:SS")) else new Date(moment("2019-01-01 00:00:00", "YYYY-MM-DD HH:MM:SS"))
#          shiftData.onTime = if shiftData.onTime then new Date(moment("2019-01-01 " + shiftData.onTime, "YYYY-MM-DD HH:MM:SS")) else new Date(moment("2019-01-01 00:00:00", "YYYY-MM-DD HH:MM:SS"))
            shiftData.startTime = if shiftData.startTime then moment(shiftData.startTime).format("YYYY-MM-DD") else ""
            shiftData.endTime = if shiftData.endTime then moment(shiftData.endTime).format("YYYY-MM-DD") else ""
            scope.groupInfo = shiftData
            index = null
            _.map(scope.shiftList, (d, i) =>
              if d.shift is shiftData.shift
                index = i
            )
            if _.isNull(index)
              scope.shiftList.unshift(shiftData)
              scope.selectNodeId = 0
            else
              scope.shiftList[index] = shiftData
              scope.selectNodeId = index
            scope.memberList = shiftData.engineers
            scope.$applyAsync()
            @loadShift(scope,(shifts)=>
              @warpShifts(scope,shifts)
            )
            @display "温馨提示：操作成功！"

    deleteShift:(scope)=>
      @shiftService.remove @current,(err,shiftData)=>
        if err
          @display err,shiftData
        else
          tmpProcess = scope.project.getIds()
          tmpProcess.process = "plan-" + @current.shift
          @processService.remove tmpProcess,(err,processData)=>
          # 置空
          scope.selectNodeId = null
          scope.memberList = []
          scope.editState = true
          scope.selectedEquipSignalList = {}
          scope.groupInfo = { shift: "", name: "", onTime:"",offTime:"",startTime:"", endTime:"",desc:"",engineers: [], addUser: "" }
          scope.shiftList = _.filter(scope.shiftList, (d) => d.shift != shiftData[0].shift)
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

    init:(scope)=>
      scope.allEquips = []
      scope.allSelectStatus = false
      tmpStations = _.filter scope.project.stations.items, (item) ->
        return item.model.station.charAt(0) != "_"

      for stationItem in tmpStations
        stationItem.loadEquipments null,null,(err, equips) ->
          if equips
            for equip in equips
              if equip.model.equipment.charAt(0) != "_"
                console.info equip
                equip.loadPoints null, (err, signals) =>
                  if signals
                    console.info signals
                    if signals.length > 0
                      equipObj = signals[0].equipment
                      equipObj.model.stationName = signals[0].station.model.name
                      scope.allEquips.push signals[0].equipment

    loadShift:(scope,callback) =>
      filter = {}
      #      filter.user = @$routeParams.user
      #      filter.project = @$routeParams.project
      #      @shiftService.query filter, null, (err, shiftModels) =>
      @commonService.loadProjectModelByService "shifts",filter, null, (err, shiftModels) =>
        if shiftModels
          @allShifts = shiftModels
        callback(shiftModels)
      ,true

#创建流程模板
    createProcessTemplate:(scope,callback)=>
      workContents = []
      for selectedEquipSignal in scope.selectedEquipSignalList
        workContents.push {orderno:selectedEquipSignal.orderno,station:selectedEquipSignal.station,stationName:selectedEquipSignal.stationName,equipment:selectedEquipSignal.equipment,equipName:selectedEquipSignal.equipName,signal:selectedEquipSignal.signal,signalName:selectedEquipSignal.signalName,value:null,setvalue:null,defect_representation:"", defect_reason:"", defect_analysis:"",loss_situation:"",severity:1,status:0,work_status:0}

      processId = "plan-" + scope.groupInfo.shift
      processName = scope.groupInfo.name + "流程"
      filter = scope.project.getIds()
      filter.process = processId
      @processService.query filter, null, (err, procesDatas) =>
        if !(_.isEmpty procesDatas)
#          procesDatas.nodes[0].contents[0].content = JSON.stringify({content:workContents,handle_details:[],attachments:[]})
          procesDatas.nodes[0].contents[0].content = {content:workContents,handle_details:[],attachments:[]}
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
            contents:[{type:"json",content:{content:workContents,handle_details:[],attachments:[]}}]

          }
          templateObj = {
            name:processName
            process:processId
            desc:scope.groupInfo.desc
            trigger:"shift"
            type:"plan"
            enable:true
            visible:true
            cancleable:true
            priority:1
            nodes:[]
          }
          templateObj.nodes.push nodeObj
          templateObj = _.extend templateObj,scope.project.getIds()
          @processService.save templateObj,(err,processData)=>
            callback? err,processData
      ,true

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
    CompWorkplanDirective: CompWorkplanDirective