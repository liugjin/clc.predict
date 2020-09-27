###
* File: comp-work-overview-directive
* User: James
* Date: 2019/12/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CompWorkOverviewDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "comp-work-overview"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.type = "day"
      scope.typeList = [
        { name: '日', key: 'day' },
        { name: '月', key: 'month' },
        { name: '年', key: 'year' }
      ]
      scope.dateArr = []
      scope.defect = { equipment: [], task: [],workitems:[],excepequips:[],excepworkitems:[],tenRank:[] }
      scope.plan = { equipment: [], task: [],workitems:[],excepequips:[],excepworkitems:[] }
      scope.predict = { equipment: [], task: [],workitems:[],excepequips:[],excepworkitems:[] }
      scope.total = { equipment: [], task: [],workitems:[],excepequips:[],excepworkitems:[] }
      
      # 更新
      update = () => (
        @getDateArr(scope)
        @getTaskCount(scope)    #获取工作工单
        @getEquipCounts(scope)   #获取工作设备
        @getEquipCheckCounts(scope) #获取工作项
        @getExcepEquipCounts(scope) #获取异常设备
        @getExcepWorkItems(scope) #获取异常工作项
      )

      updateLazy = _.throttle(update, 500, { leading: true })

      scope.subTimeType?.dispose()
      scope.subTimeType = @commonService.subscribeEventBus("task-type", (msg) =>
        return if !msg
        if scope.dateArr.length == 0
          updateLazy()
        else if scope.type != msg.message.type
          scope.type = msg.message.type
          updateLazy()
      )

    # 获取时间数组
    getDateArr: (scope) => (
      exec = if scope.type == "year" then 3 else 5
      map = { day: "MM-DD", month: "YYYY-MM", year: "YYYY" }
      scope.dateArr = _.map([exec..0], (d) => 
        time = moment().subtract(d, scope.type).format(map[scope.type])
        return time
      )
      scope.$applyAsync()
    )

    # 判断工单状态
    getTaskStatus: (phase) -> (
      # stateMap = { 1: "等待处理", 2: "拒绝", 3: "取消", 4: "进行中", 5: "已结束" }
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
      return (status == 1 or state == 4)
    )

    # 获取各个类型的工单总数
    getTaskCount: (scope) =>
      aggregateCons = []
      matchObj = {}
      groupObj = {}

      type = scope.type
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

      filter = scope.project.getIds()
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}
      groupObj.$group = {_id:{createtime:{ $dateToString: { format: formatTypeMap[type], date: "$createtime" } },type:"$type",phase:"$phase.nextNode"},total_sheets:{$sum:1}}

      matchObj.$match = filter

      aggregateCons.push matchObj
      aggregateCons.push groupObj
      @commonService.reportingService.aggregateTasks {filter:scope.project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        return if !records
        if records.length == 0
          _.each(["defect", "plan", "predict", "total"], (d) =>
            scope[d].task = []
          )
        else
          tasks = []
          _.each(["defect", "plan", "predict"], (d) =>
            scope[d].task = _.map(_.filter(records, (m) => m._id.type == d), (m) => (
              item = {
                val: m.total_sheets,
                time: moment(m._id.createtime).format(formatTypeMap2[scope.type]),
                type: m._id.type
                phase:m._id.phase
              }
              return item
            ))
            tasks = tasks.concat(scope[d].task)
          )
          scope.total.task = tasks

    #根据时间条件获取所有工作项
    getEquipCheckCounts: (scope) =>
      aggregateCons = []
      matchObj = {}
      groupObj = {}

      type = scope.type
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

      filter = scope.project.getIds()
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}
      groupObj.$group = {_id:{type:"$type",phase:"$phase.nextNode",createtime:{$dateToString:{format: formatTypeMap[type],date:"$createtime"}}},total_equips:{$sum:"$workequips"}}

      matchObj.$match = filter
      aggregateCons.push matchObj
      aggregateCons.push {$project:{_id:1,type:1,phase:1,"nodes.contents.content.content":1,createtime:1,"workcontent":"$nodes.contents.content.content"}}
      aggregateCons.push {$unwind:"$workcontent"}
      aggregateCons.push {$project:{_id:1,type:1,phase:1,createtime:1,"workequips":{$sum:{$map:{input:"$workcontent",as:"workitem",in:{$size:{ $cond:{if:{ $isArray: "$$workitem" },then: "$$workitem",else: []}}}}}}}}
      aggregateCons.push groupObj
      @commonService.reportingService.aggregateTasks {filter:scope.project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        return if !records
        if records.length == 0
          _.each(["defect", "plan", "predict", "total"], (d) =>
            scope[d].workitems = []
          )
        else
          scope.total.workitems = []
          _.each(["defect", "plan", "predict"], (d) =>
            scope[d].workitems = _.map(_.filter(records, (m) => m._id.type == d), (n) => (
              item = n._id
              item.val = n.total_equips
              item.time = moment(n._id.createtime).format(formatTypeMap2[scope.type])
              return item
            ))
            scope.total.workitems = scope.total.workitems.concat(scope[d].workitems)
          )

    #根据时间条件获取所有设备
    getEquipCounts: (scope) =>
      aggregateCons = []
      matchObj = {}

      type = scope.type
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
      filter = scope.project.getIds()
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}

      matchObj.$match = filter
      aggregateCons.push matchObj
      aggregateCons.push  {$unwind:"$nodes"}
      aggregateCons.push {$unwind:"$nodes.contents"}
      aggregateCons.push {$unwind:"$nodes.contents.content.content"}
#      aggregateCons.push {$project:{_id:1,type:1,phase:1,createtime:1,"workequips":{$sum:{$map:{input:"$workcontent",as:"workitem",in:{$size:"$$workitem"}}}}}}
      aggregateCons.push {$group: {_id: {type:"$type",phase:"$phase.nextNode",createtime:{$dateToString:{format: formatTypeMap[scope.type],date:"$createtime"}},task:"$task",station:"$nodes.contents.content.content.station",equipment:"$nodes.contents.content.content.equipment"}}}
      aggregateCons.push {$group: {_id: {type:"$_id.type",phase:"$_id.phase",createtime:"$_id.createtime"},equips:{$sum:1}}}
#      if scope.type is "day"
#        aggregateCons.push {$group: {_id: {type:"$_id.type",phase:"$_id.phase",createtime:"$_id.createtime"},equips:{$sum:1}}}
#      else if scope.type is "month"
#        aggregateCons.push {$group: {_id: {type:"$_id.type",phase:"$_id.phase",createtime:{$substr:["$_id.createtime",0,7]}},equips:{$sum:1}}}
#      else if scope.type is "month"
#        aggregateCons.push {$group: {_id: {type:"$_id.type",phase:"$_id.phase",createtime:{$substr:["$_id.createtime",0,4]}},equips:{$sum:1}}}
      @commonService.reportingService.aggregateTasks {filter:scope.project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        return if !records
        if records.length == 0
          _.each(["defect", "plan", "predict", "total"], (d) =>
            scope[d].equipment = []
          )
        else
          scope.total.equipment = []
          _.each(["defect", "plan", "predict"], (d) =>
            scope[d].equipment = _.map(_.filter(records, (m) => m._id.type == d), (n) => (
              item = n._id
              item.val = n.equips
              item.time = moment(n._id.createtime).format(formatTypeMap2[scope.type])
              return item
            ))
            scope.total.equipment = scope.total.equipment.concat(scope[d].equipment)
          )

    #根据时间条件获取所有异常设备
    getExcepEquipCounts: (scope) =>
      aggregateCons = []
      matchObj = {}

      type = scope.type
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

      filter = scope.project.getIds()
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}

      matchObj.$match = filter
      aggregateCons.push matchObj
      aggregateCons.push  {$unwind:"$nodes"}
      aggregateCons.push {$unwind:"$nodes.contents"}
      aggregateCons.push {$unwind:"$nodes.contents.content.content"}
      aggregateCons.push matchObj
      aggregateCons.push {$group: {_id: {type:"$type",phase:"$phase.nextNode",createtime:{$dateToString:{format: formatTypeMap[scope.type],date:"$createtime"}},task:"$task",station:"$nodes.contents.content.content.station",equipment:"$nodes.contents.content.content.equipment"}}}
      aggregateCons.push {$group: {_id: {type:"$_id.type",phase:"$_id.phase",createtime:"$_id.createtime"},equips:{$sum:1}}}

      @commonService.reportingService.aggregateTasks {filter:scope.project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        return if !records
        if records.length == 0
          _.each(["defect", "plan", "predict", "total"], (d) =>
            scope[d].excepequips = []
          )
        else
          scope.total.excepequips = []
          _.each(["defect", "plan", "predict"], (d) =>
            scope[d].excepequips = _.map(_.filter(records, (m) => m._id.type == d), (n) => (
              item = n._id
              item.val = n.equips
              item.time = moment(n._id.createtime).format(formatTypeMap2[scope.type])
              return item
            ))
            scope.total.excepequips = scope.total.excepequips.concat(scope[d].excepequips)
          )

    #根据时间条件获取所有异常工作项
    getExcepWorkItems: (scope) =>
      aggregateCons = []
      matchObj = {}

      type = scope.type
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
      filter = scope.project.getIds()
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}

      matchObj.$match = filter
      aggregateCons.push matchObj
      aggregateCons.push  {$unwind:"$nodes"}
      aggregateCons.push {$unwind:"$nodes.contents"}
      aggregateCons.push {$unwind:"$nodes.contents.content.content"}
      aggregateCons.push matchObj
      if scope.type is "day"
        aggregateCons.push {$group: {_id: {type:"$type",phase:"$phase.nextNode",createtime:{$dateToString:{format: formatTypeMap.day,date:"$createtime"}}},equips:{$sum:1}}}
      else if scope.type is "month"
        aggregateCons.push {$group: {_id: {type:"$type",phase:"$phase.nextNode",createtime:{$dateToString:{format: formatTypeMap.month,date:"$createtime"}}},equips:{$sum:1}}}
      else if scope.type is "year"
        aggregateCons.push {$group: {_id: {type:"$type",phase:"$phase.nextNode",createtime:{$dateToString:{format: formatTypeMap.year,date:"$createtime"}}},equips:{$sum:1}}}

      @commonService.reportingService.aggregateTasks {filter:scope.project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        return if !records
        if records.length == 0
          _.each(["defect", "plan", "predict", "total"], (d) =>
            scope[d].excepworkitems = []
          )
        else
          scope.total.excepworkitems = []
          _.each(["defect", "plan", "predict"], (d) =>
            scope[d].excepworkitems = _.map(_.filter(records, (m) => m._id.type == d), (n) => (
              item = n._id
              item.val = n.equips
              item.time = moment(n._id.createtime).format(formatTypeMap2[scope.type])
              return item
            ))
            scope.total.excepworkitems = scope.total.excepworkitems.concat(scope[d].excepworkitems)
          )

    #根据时间条件获取所有设备故障数
    getEquipDefectCounts: (scope) =>
      aggregateCons = []
      matchObj = {}

      type = scope.type
      execCount = if type == "year" then 3 else 5

      # 格式化返回的时间
      formatTypeMap = {
        day: "%Y-%m-%d",
        month: "%Y-%m",
        year: "%Y"
      }

      filter = scope.project.getIds()
      filter.type = "defect"
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}

      matchObj.$match = filter
      aggregateCons.push matchObj

      if scope.type is "day"
        aggregateCons.push {$group: {_id: {station:"$source.station",stationName:"$source.stationName",equipment:"$source.equipment",equipmentName:"$source.equipmentName"},equips:{$sum:1}}}
      else if scope.type is "month"
        aggregateCons.push {$group: {_id: {station:"$source.station",stationName:"$source.stationName",equipment:"$source.equipment",equipmentName:"$source.equipmentName"},equips:{$sum:1}}}
      else if scope.type is "year"
        aggregateCons.push {$group: {_id: {station:"$source.station",stationName:"$source.stationName",equipment:"$source.equipment",equipmentName:"$source.equipmentName"},equips:{$sum:1}}}

      @commonService.reportingService.aggregateTasks {filter:scope.project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        return if !records


    resize: (scope) ->

    dispose: (scope) ->
      scope.subTimeType?.dispose()

  exports =
    CompWorkOverviewDirective: CompWorkOverviewDirective