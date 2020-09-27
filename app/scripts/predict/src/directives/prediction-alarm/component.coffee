###
* File: prediction-alarm-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class PredictionAlarmDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "prediction-alarm"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @setData(scope,element)
#      scope.stationEventBus?.dispose()
#      scope.stationEventBus = @commonService.subscribeEventBus 'stationID',(msg)=>
#        stationID = msg.message.data
#        @commonService.loadStation stationID, (err,station) =>
#          scope.station = station
#          scope.eventSubscriptionArray.forEach (sub)=>
#            sub.dispose()
#          @setData(scope,element)
    setData:(scope,element)=>
      scope.events = {}
      scope.eventsArray = []
      scope.xData = []
      scope.seriesData = []
      scope.eventSubscriptionArray = []
      # 在订阅之前先清空图表数据并对图表进行图表渲染
      scope.eventsArray.splice(0,scope.eventsArray.length)
      scope.xData.splice(0,scope.xData.length)
      scope.seriesData.splice(0,scope.seriesData.length)
      @createLineCharts(scope,element)
      @subscribeValues(scope,element)
    subscribeValues:(scope,element)=>
      # 订阅告警信息
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
      eventSubscription=@commonService.eventLiveSession.subscribeValues filter,(err,msg) =>
        return console.log(err) if err
        @processEvent(scope,element,msg)
      scope.eventSubscriptionArray.push(eventSubscription)
    # 处理订阅回来的告警
    processEvent:(scope,element,data) =>
      return if not data
      message = data.message
      key = "#{message.user}.#{message.project}.#{message.station}.#{message.equipment}.#{message.event}.#{message.severity}.#{message.startTime}"
      if scope.events.hasOwnProperty key
        event = scope.events[key]
        for k, v of message
          event[k] = v
      else
        event = angular.copy message
        scope.events[key] = event
        if(event.eventType == "divine" and event.phase == "start")
          scope.eventsArray.push event
          @groupArr(scope,element,"equipmentName")
    # 根据设备名称的键名对告警进行分组
    groupArr:(scope,element,field)=>
      if(scope.eventsArray.length>0)
        obj = {};
        for ev in scope.eventsArray
          for item of ev
            if(item == field)
              obj[ev[item]] = 
                list: if obj[ev[field]] then obj[ev[field]].list else [],
                type: ev[field]
          obj[ev[field]].list.push(ev)
        att = []
        for item of obj
          att.push({
            list: obj[item].list,
            type: obj[item].type
          })
        @setEchartsData(scope,element,att)
    # 处理图表数据
    setEchartsData:(scope,element,att)=>
      scope.xData.splice(0,scope.xData.length)
      scope.seriesData.splice(0,scope.seriesData.length)
      for va in att
        scope.xData.push va.type
#        scope.seriesData.push @addZero(va.list.length)
        scope.seriesData.push va.list.length
      @createLineCharts(scope,element)
    # 图表渲染
    createLineCharts: (scope,element) =>
      line = element.find(".echartsContent")
      scope.echart?.dispose()
      option =
        color: ['#00A7FF']
        tooltip:
          trigger: 'axis'
          axisPointer:
            type: 'shadow'
        grid:
          left: '3%',
          right: '4%',
          bottom: '6%',
          containLabel: true
        xAxis:
          type: 'category',
          data: scope.xData
          axisLine:
            lineStyle:
              color: "#FFFFFF"
          splitLine:
            show: false
            lineStyle:
              color: "rgba(0,77,160,1)"
        yAxis:
          type: 'value'
          minInterval: 1
          axisLine:
            lineStyle:
              color: "#F5FCFF"
          splitLine:
            show: false
            lineStyle:
              color: "rgba(0,77,160,1)"
        series: [
          {
            type:'bar',
            barGap: '0%',
            name:'预测告警',
            data:scope.seriesData
            markPoint:
              data:[
                {type:'max',name:'最大值'}
              ]
          }
        ]

      scope.echart = echarts.init line[0]
      scope.echart.setOption option

      scope.resize=()=>
        @$timeout =>
          scope.echart?.resize()
        ,100
      window.addEventListener 'resize', scope.resize
      window.dispatchEvent(new Event('resize'))

    # 小于2位数前面补0
    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num
    resize: (scope)->

    dispose: (scope)->
#      scope.stationEventBus?.dispose()
      scope.eventSubscriptionArray.forEach (sub)=>
        sub.dispose()

  exports =
    PredictionAlarmDirective: PredictionAlarmDirective