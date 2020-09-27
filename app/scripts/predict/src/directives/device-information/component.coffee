###
* File: device-information-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceInformationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-information"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.eventRecords = []#预测性告警
      scope.eventSeverity = scope.project?.typeModels?.eventseverities?.items
      @setTime(scope,element)
      @queryAlarms(scope,1,7,'divine')#预测性告警 默认获取当天的
      # 查询
      scope.getReportData=() =>
        @queryAlarms(scope,1,7,'divine')#预测性告警
      # 页面切换
      scope.queryPage = (page) =>
        paging = scope.pagination
        return if not paging
        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1
        return if page > paging.pageCount or page < 1
        scope.eventRecords = []
        @queryAlarms(scope,page,paging.pageItems,'divine')#预测性告警
    # 设置选择时间
    setTime:(scope,element) =>
      scope.query =
        startTime : moment().format("YYYY-MM-DD")
        endTime : moment().format("YYYY-MM-DD")
      setGlDatePicker = (element,value)->
        return if not value
        setTimeout ->
          gl = $(element).glDatePicker({
            dowNames:["日","一","二","三","四","五","六"],
            monthNames:["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"],
            selectedDate: moment(value).toDate()
            onClick:(target,cell,date,data)->
              month = date.getMonth()+1
              if month < 10
                month = "0"+ month
              day = date.getDate()
              if day < 10
                day = "0"+ day
              target.val(date.getFullYear()+"-"+month+"-"+day).trigger("change")
          })
        ,500
      setGlDatePicker($('#start-time-input')[0],scope.query.startTime)
      setGlDatePicker($('#end-time-input')[0],scope.query.startTime)

    # 查询 当前站点的告警事件 并设置页面
    queryAlarms:(scope,page=1,pageItems=8,eventType)=>
      scope.showBox = false
      filter = scope.project.getIds()
      filter.station = scope.station.model.station
      filter.equipment = scope.equipment.model.equipment
      filter.eventType = eventType
      filter.startTime = moment(scope.query.startTime).startOf('day')
      filter.endTime = moment(scope.query.endTime).endOf('day')
      paging =
        page: page
        pageItems: pageItems
      data =
        filter: filter
        fields: null
        paging: paging
        sorting: {station:1,equipment:1,timestamp:-1}
      scope.dataEventRecords = []
      scope.dataIntellect = []
      @commonService.reportingService.queryEventRecords data, (err, records, paging2) =>
        scope.eventRecords = records
        for event in scope.eventRecords
          scope.eventSeverity.forEach (e)=>
            event.color = e?.model?.color if event?.severity is e?.model?.severity

        pCount = paging2?.pageCount or 0
        if pCount <= 6
          paging2?.pages = [1..pCount]
        else if page > 3 and page < pCount-2
          paging2?.pages = [1, page-2, page-1, page, page+1, page+2, pCount]
        else if page <=3
          paging2?.pages = [1, 2, 3, 4, 5, 6, pCount]
        else if page >= pCount-2
          paging2?.pages = [1, pCount-5, pCount-4, pCount-3, pCount-2, pCount-1, pCount]
        scope.pagination = paging2

      # 跳转页面
      scope.clickEvent = (event)=>
        console.log event
#        console.log("deviceData",deviceData)
        window.location.hash = "#/event-analysis/#{event.user}/#{event.project}?station=#{event.station}&equipment=#{event.equipment}"
    resize: (scope)->

    dispose: (scope)->


  exports =
    DeviceInformationDirective: DeviceInformationDirective