###
* File: defecttask-card-directive
* User: David
* Date: 2019/12/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DefecttaskCardDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "defecttask-card"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 故障工单

      scope.count = 0


      scope.warnSeries = [
        { key: "common", name: "故障工单", color: 'rgb(193, 201, 80)' }
      ]

      scope.date = []

      scope.warnData = [
        # { key: "common", time: "2019-5-12", val: 51 },
        # { key: "dangerous", time: "2019-5-12", val: 51 },
        # { key: "serious", time: "2019-5-12", val: 51 },
        # { key: "common", time: "2019-5-13", val: 51 }
      ]

      scope.transData = [
        { key: "待处理", val: 0 },
        { key: "进行中", val: 0 }
      ]

      scope.type = "day"

      keyMap = {
        day: ["本日待处理故障", "近五日前十故障设备"],
        month: ["本月待处理故障", "近五月前十故障设备"],
        year: ["今年待处理故障", "近三年前十故障设备"]
      }

      scope.equipData = [
        { key: "待处理故障", val: 0, max: 100 }
#        { key: "故障数前十设备", val: 0, max: 100 }
      ]
      scope.rankData = [
        # { id: "task-defect", key: "故障工单", stack: "defect", val: 30, sort: 0 }
      ]
      scope.$watch("parameters", (param) =>
        return if !param
        scope.date = param.date if scope.date.length == 0

        if scope.type != param.type
          scope.type = param.type
          scope.date = param.date
        tmpHandlingCounts = 0
        count = 0
        scope.warnData = _.map param.data.task, (task) ->
          if !(_.isEmpty task.phase)
            tmpHandlingCounts += task.val
          count += task.val
          {key: 'common', val: task.val, time: task.time}

        scope.count = count

        handleResult =  _.find scope.equipData,{key:"待处理故障"}
        handleResult.val = tmpHandlingCounts

        scope.$applyAsync()


      )
      scope.$watch "parameters.type", (type) =>
        return if not scope.firstload
          scope.rankData = [
            { id: "task-defect", key: "故障工单", stack: "defect", val: 30, sort: 0 }
            { id: "task-plan", key: "巡检工单", stack: "defect", val: 30, sort: 1 }
            { id: "task-predict", key: "维保工单", stack: "defect", val: 30, sort: 2 }
          ]
          @getEquipDefectCount(scope)
          scope.$applyAsync()


    # 根据站点设备统计故障数
    getEquipDefectCount: (scope) =>
      aggregateCons = []
      matchObj = {}
      groupObj = {}

      type = scope.parameters.type
      execCount = if scope.parameters.type == "year" then 3 else 5

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
      filter.type = "defect"
      filter.createtime = {$gte:moment().subtract(execCount, type).startOf(type),$lte:moment().endOf(type)}
      groupObj.$group = {_id:{station:"$source.station",equipment:"$source.equipment",stationName:"$source.stationName",equipmentName:"$source.equipmentName"},defects:{$sum:1}}

      matchObj.$match = filter

      aggregateCons.push matchObj
      aggregateCons.push groupObj
      aggregateCons.push {$sort:{defects:-1}}
      @commonService.reportingService.aggregateTasks {filter:scope.project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
        #记录格式是[{_id:{station: "shandong", equipment: "air-condition", stationName: "山东高速", equipmentName: "空调"},defects:1}]
         return if !records
         scope.rankData = []
         recount = 0

         for rec in records
           scope.rankData.push {
             id: rec._id.station + "." + rec._id.equipment,
             key: rec._id.stationName + "." + rec._id.equipmentName,
             stack: "故障数前十设备",
             val: rec.defects,
             sort: recount
           }
           recount++

         console.info scope.rankData
        #根据竖堆叠图格式
    resize: (scope) ->

    dispose: (scope) ->

  exports =
    DefecttaskCardDirective: DefecttaskCardDirective