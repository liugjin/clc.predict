###
* File: task-table-directive
* User: David
* Date: 2019/11/14
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class TaskTableDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "task-table"
      super $timeout, $window, $compile, $routeParams, commonService
      @taskRecordService = commonService.modelEngine.modelManager.getService("reporting.records.task")
      @taskService = commonService.modelEngine.modelManager.getService("tasks")
      @processtypesService = commonService.modelEngine.modelManager.getService("processtypes")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      prioritiesMap = { 1: "低", 2: "中", 3: "高" }
      
      allData = []
      scope.processtypes = {}

      scope.data = []

      scope.pages = { page: [], current: 1 } # 分页参数, 专用于刷新分页
      
      scope.currentType = ''
      scope.count = {}
      
      scope.lastQuery = scope.project.getIds()

      timeTranform = (d) => (
        return null if !d
        str = moment(d).format()
        return str.slice(0, 19).split("T").join(" ")
      ) 
      
      # 完成状态label
      colorMap = { 1: "#14C3F5", 2: "#F53914", 3: "#FF800B", 4: "#32CA59", 5: "#BECA32" }
      # 优先级label
      colorMap2 = { 1: "#14C3F5", 2: "#F53914", 3: "#FF800B", 4: "#32CA59", 5: "#BECA32" }
      # 告警等级
      colorMap3 = { 1: "#c0ca33", 2: "#ff9800", 3: "#ff8000", 4: "#ff0000" }
      
      scope.tableConfig = []

      # 分页初始化
      initPage = (len) => (
        arr = []
        if len > 0
          count = Math.ceil(len / 10)
          if count <= 10
            arr.push(x) for x in [count..1]
          else
            for x in [count..1]
              if x <= 3 || x >= count - 2
                arr.push(x) 
              else if x == 4
                arr.push(-2)
              else if x == count - 3
                arr.push(-1)
        scope.pages = { page: arr, current: 1 }
      )
      
      changeTable = (type) => (
        if type == "defect"
          scope.tableConfig = [
            { title: "工单号", id: "task", class: "task" },
            { title: "工单类型", id: "type", class: "" },
            { title: "完成状态", id: "phase", class: "colorItem", color: colorMap, formate: (d) => @getStatusName(d) },
            { title: "最近更新时间", id: "updatetime", class: "time", formate: timeTranform },
            { title: "故障原因", id: "source", formate: (d) -> d.title },
            { title: "故障值", id: "source", formate: (d) -> d.startValue },
            { title: "故障开始时间", id: "source", formate: (d) => timeTranform(d?.startTime) },
            { title: "优先级", id: "priority", class: "colorItem", color: colorMap2, formate: (d) => prioritiesMap[d] },
            { title: "告警等级", id: "source", class: "colorItem", color: colorMap3 },
            { title: "创建人", id: "creator", class: "name", formate: (d) => d.name },
            { title: "备注", id: "memo", class: "" }
          ]
        else 
          scope.tableConfig = [
            { title: "工单号", id: "task", class: "task" },
            { title: "工单名称", id: "name", class: "task" },
            { title: "工单类型", id: "type", class: "" },
            { title: "完成状态", id: "phase", class: "colorItem", color: colorMap, formate: (d) => @getStatusName(d) },
            { title: "工单创建时间", id: "createtime", class: "time", formate: timeTranform }, 
            { title: "最近更新时间", id: "updatetime", class: "time", formate: timeTranform },
            { title: "优先级", id: "priority", class: "colorItem", color: colorMap2, formate: (d) => prioritiesMap[d] },
            { title: "创建人", id: "creator", class: "name", formate: (d) => d.name },
            { title: "备注", id: "memo", class: "" }
          ]
      )
      
      # 数据源获取
      getDataSource = (param, isInit) => (
        filter = scope.project.getIds()
        if isInit && !param
          filter["createtime"] = { 
            "$gte": moment().subtract(7, 'days').format('YYYY-MM-DD 00:00:00'), 
            "$lte": moment().format('YYYY-MM-DD 23:59:59')
          }
        else
          filter = param
        scope.lastQuery = filter
        @commonService.loadProjectModelByService('tasks', filter, null, (err, resp) =>
          return @display("工单查询失败!!", 500) if !resp
          _data = _.filter(resp, (m) -> m.visible)
          allData = _.groupBy(_data, (d) -> d.type)
          scope.count = _.mapObject(scope.count, (d, i) => 
            if _.has(allData, i)
              return allData[i].length
            else
              allData[i] = []
              return 0
          )
          changeTable(scope.currentType)
          if isInit
            initPage(allData[scope.currentType].length)
            scope.data = allData[scope.currentType].slice(0, 10)
          else
            current = scope.pages.current
            scope.data = allData[scope.currentType].slice((current - 1) * 10, current * 10)
          scope.$applyAsync()
        , true)
      )
      
      getDataSourceLazy = _.throttle(getDataSource, 1000, { leading: false })

      # 初始化
      init = () => (
        if _.isEmpty(scope.processtypes)
          filter = scope.project.getIds()
          @processtypesService.query(filter, null, (err, datas) =>
            return @display("查询工单类型失败/为空!!", 500) if !datas or datas?.length == 0
            _datas = _.sortBy(_.filter(datas, (m) -> m.visible), (d) -> d._index)
            scope.currentType = _datas[0].type
            scope.processtypes = _.object(_.map(_datas, (d) -> d.type), _.map(_datas, (d) -> d.name))
            scope.count = _.mapObject(scope.processtypes, (d) -> 0)
            getDataSourceLazy(null, true)
          )
        else
          getDataSourceLazy(null, true)
      )

      init()

      # 导出
      scope.export = () => (
        return @display("当前列表为空!!", 500) if allData[scope.currentType].length == 0
        current = scope.processtypes[scope.currentType]
        data = _.map(allData[scope.currentType], (row) =>
          arr = {}
          _.each(scope.tableConfig, (col) =>
            return arr["type"] = current if col.id == "type"
            if _.has(row, col.id) and _.has(col, "formate")
              arr[col.title] = if row[col.id] then col.formate(row[col.id]) else ""
            else if _.has(row, col.id)
              arr[col.title] = if row[col.id] then row[col.id] else ""
            else
              arr[col.title] = ""
          )
          return arr
        )
        
        wb = XLSX.utils.book_new();
        excel = XLSX.utils.json_to_sheet(data)
        XLSX.utils.book_append_sheet(wb, excel, "Sheet1")
        XLSX.writeFile(wb, current + "-" + moment().format('YYYYMMDDHHMMSS') + ".xlsx")
      )

      # 工单操作
      scope.edit = (task) => @commonService.publishEventBus("task-model", { open: true, task, isEdit: true })

      # 详情查看
      scope.info = (task) => @commonService.publishEventBus("task-model", { open: true, task, isEdit: false })

      # 删除工单
      scope.delete = (task) => (
        @taskService.remove(task, (err, taskdata) =>
          return if err
          @dispose("删除成功", 500)
          getDataSourceLazy(scope.lastQuery, false)
        )
      )

      # 类型切换
      scope.changeType = (type) => (
        return if scope.currentType == type
        changeTable(type)
        scope.currentType = type
        initPage(allData[type].length)
        scope.data = allData[type].slice(0, 10)
        scope.$applyAsync()
      )

      checkPage = (pages) -> (
        _pages = _.uniq(pages)
        _pageItems = _.filter(_pages, (d) -> d > 0)
        if _pageItems.length == 6
          return pages
        else
          _pageItems.push(-5) if _pages[_pages.length - 1] == 0
          _pageItems.unshift(-4) if _pages[0] == -3
          return _pageItems
      )
      
      # 分页点击切换页面
      scope.update = (page) => (
        return if scope.pages.current == page
        count = Math.ceil(allData[scope.currentType].length / 10)
        if page <= 0 && count > 10
          if scope.pages.page.indexOf(-1) == -1 && scope.pages.page.indexOf(-2) == -1
            if page == -4
              max = _.max(scope.pages.page)
              min = _.min(_.filter(scope.pages.page, (p) -> p > 0))
              scope.pages.page = [max + 3, max + 2, max + 1, -1, -2, min + 2, min + 1, min]
            else if page == -5
              max = _.max(scope.pages.page)
              min = _.min(_.filter(scope.pages.page, (p) -> p > 0))
              scope.pages.page = [max, max - 1, max - 2, -1, -2, min - 1, min - 2, min - 3]
            scope.pages.page.unshift(-3) if scope.pages.page[0] != count 
            scope.pages.page.push(0) if scope.pages.page[scope.pages.page.length - 1] != count   
            return scope.$applyAsync()
          len = scope.pages.page.length
          if page == 0
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i >= 5 && d > 0) then d - 3 else d)
            scope.pages.page = _.filter(scope.pages.page, (d) -> d != 0) if scope.pages.page[len - 1] == 0 && scope.pages.page[len - 2] == 1   
          else if page == -1
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i <= 3 && d > 0) then d - 3 else d)
            scope.pages.page.unshift(-3) if scope.pages.page[0] > 0 && scope.pages.page != count 
          else if page == -2
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i >= 5 && d > 0) then d + 3 else d)
            scope.pages.page.push(0) if scope.pages.page[len - 1] > 1
          else if page == -3
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i <= 3 && d > 0) then d + 3 else d)
            scope.pages.page = _.filter(scope.pages.page, (d) -> d != -3) if scope.pages.page[1] == count
          scope.pages.page = checkPage(scope.pages.page)
          return scope.$applyAsync()
        scope.pages.current = page
        scope.data = allData[scope.currentType].slice(10 * page - 10, 10 * page)
        scope.$applyAsync()
      )

      # 订阅查询参数
      scope.subscribePage?.dispose()
      scope.subscribePage = @commonService.subscribeEventBus("task-query", (msg) =>
        return if !msg?.message
        if typeof(msg.message) != "string"
          query = msg.message
          query["createtime"] = { 
            "$gte": moment(msg.message.createtime["$gte"]).format('YYYY-MM-DD 00:00:00'), 
            "$lte": moment(msg.message.createtime["$lte"]).format('YYYY-MM-DD 23:59:59')
          }
          getDataSourceLazy(query, true) 
      )
      
      # 处理故障工单
      warpSource = (d, data) => (
        if data == ""
          return {
            "startTime": d.startTime,
            "station": d.station,
            "stationName": d.stationName,
            "equipment": d.equipment,
            "equipName": d.equipmentName,
            "event": d.event,
            "eventName": d.eventName,
            "startValue": d.startValue,
            "defect_representation": "",
            "defect_reason": d.title,
            "defect_analysis": "",
            "loss_situation": "",
            "work_status": d.work_status,
            "startTime": timeTranform(d.startTime),
            "severity": d.severity,
            "severityName": d.severityName
          }
        if data.startValue != d.startValue or data.startTime != timeTranform(d.startTime) or data.severity != d.severity
          return false
        data.startValue = d.startValue 
        data.startTime = timeTranform(d.startTime)
        data.severity = d.severity
        return data
      )  
      
      # 订阅工单变化
      scope.subPlanTaskChange?.dispose()
      scope.subPlanTaskChange = @commonService.configurationLiveSession.subscribe("tasks/" + scope.$root.user.user + "/#", (err, d) =>
        return if not d
        if d.topic.indexOf("configuration/task/create/") is 0 or d.topic.indexOf("configuration/task/update/") is 0
          if d.message.type == "defect"
            # 当为故障工单时, 先使用update更新json
            data = d.message.nodes[0].contents[0].content
            status = @getStatusName(d.message.phase)
            if status == 1 || status == 4
              task = d.message
              node = warpSource(d.message.source, data)
              if node
                task.nodes[0].contents[0].content = { 
                  content: [node], 
                  handle_details: [], 
                  attachments: [] 
                }
                @taskService.save(task, (err, taskData) =>
                  getDataSourceLazy(scope.lastQuery, false)
                , true)
                return
          getDataSourceLazy(scope.lastQuery, false)
      )
      
      scope.stateMap = { 1: "等待处理", 2: "拒绝", 3: "取消", 4: "进行中", 5: "已结束" }
      
    getStatusName: (phase) -> (
      status = 0
      if _.isEmpty(phase?.nextManager) && !(phase?.progress >= 0)
        status = 1
      else if phase?.state is "reject"
        status = 2
      else if phase?.state is "cancel"
        status = 3
      else if (phase?.progress < 1) || !_.isEmpty(phase?.nextManager)
        status = 4
      else
        status = 5
      return status
    )

    resize: (scope)->

    dispose: (scope)->
      scope.subscribePage?.dispose()
      scope.subPlanTaskChange?.dispose()

  exports =
    TaskTableDirective: TaskTableDirective