###
* File: wisdom-predict-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class WisdomPredictDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "wisdom-predict"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.eventRecords = []#预测性告警
      scope.intellect = []#智能运维
      scope.equipment = null #选择的设备
      @setTime(scope,element)
      @getDevice(scope)
      @queryAlarms(scope,1,8,'divine',scope.eventRecords)#预测性告警 默认获取当天的
      #      @queryAlarms(scope,1,8,'intellect',scope.intellect)#智能运维 默认获取当天的

      # 窗口切换
      scope.focus = 1
      scope.clickTime=(i)=>
        scope.focus = i
        if i == 1
          @queryAlarms(scope,1,8,'divine',scope.eventRecords)
        else
          @queryAlarms(scope,1,8,'intellect',scope.intellect)
      # 打开设备选择页
      scope.showBox = false
      scope.switchClick=()=>
        if scope.showBox
          scope.showBox = false
        else
          scope.showBox = true
      # 点击设备卡片选择设备
      scope.deviceClick=(i,data)=>
        scope.equipment = data
        scope.clickNum = i
      # 查询
      scope.getReportData=() =>
        if scope.focus == 1
          @queryAlarms(scope,1,8,'divine',scope.eventRecords)#预测性告警
        else
          @queryAlarms(scope,1,8,'intellect',scope.intellect)#智能运维

      # 页面切换
      scope.queryPage = (page) =>

        paging = scope.pagination
        return if not paging
        if page is 'next'
          page = paging.page + 1
#          if paging.page <=4
#            page = paging.page + 1
#          else
#            console.log("打开更多页面")
#            return
        else if page is 'previous'
          page = paging.page - 1
        return if page > paging.pageCount or page < 1

        #        @queryAlarms(scope,page,paging.pageItems)
        scope.eventRecords = []
        scope.intellect = []
        if scope.focus == 1
          @queryAlarms(scope,page,paging.pageItems,'divine',scope.eventRecords)#预测性告警
        else
          @queryAlarms(scope,page,paging.pageItems,'intellect',scope.intellect)#智能运维

# 获取设备数量
    getDevice:(scope)=>
      scope.motor = [] #电机设备
      scope.inverter = [] #变频器
      scope.allMotorNumber = 0 #投放电机数量
      scope.allInverterNumber = 0 #投放的变频器数量
      # 获取该站点下的所有设备
      scope.station.loadEquipments null, null, (err, equipments)=>
        for eq in equipments
          if eq.model.template == 'motor'
            scope.motor.push eq
          if eq.model.template == 'inverter'
            scope.inverter.push eq
        scope.allMotorNumber =@addZero(scope.motor.length)
        scope.allInverterNumber =@addZero(scope.inverter.length)

#  设置选择时间
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
    queryAlarms:(scope,page=1,pageItems=8,eventType,arrData)=>
      scope.showBox = false
      filter = scope.project.getIds()
      filter.station = scope.station.model.station
      if scope.equipment != null #选择了某个设备
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
        console.log(records)
        for all in records
          all.date = all.createtime.split("T")[0]
          all.time = all.createtime.split("T")[1].split(".")[0]
          all.textColor = "ico-color" + all.severity
          if all.eventType == 'divine'
            scope.eventRecords.push all
          if all.eventType == 'intellect'
            scope.intellect.push all

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
        console.log paging2

    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num

    resize: (scope)->

    dispose: (scope)->


  exports =
    WisdomPredictDirective: WisdomPredictDirective