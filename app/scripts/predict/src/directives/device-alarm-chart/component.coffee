###
* File: device-alarm-chart-directive
* User: David
* Date: 2020/02/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class DeviceAlarmChartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-alarm-chart"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      console.log("equipment",scope.equipment)
      @subscribeValues(scope,element)
    subscribeValues:(scope,element)=>
      scope.chartsDataArr = []
      scope.eventTotal = 0
      scope.events = {}
      scope.eventSubscriptionArray = []
      scope.eventsArray = []
      scope.eventType = scope.project.typeModels.eventtypes.items
      @createLineCharts(scope,element)
      # 订阅告警信息
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
        equipment: scope.equipment.model.equipment
      eventSubscription=@commonService.eventLiveSession.subscribeValues filter,(err,msg) =>
        return console.log(err) if err
        if msg.message.phase is 'start'
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
        if(event.equipment == scope.equipment.model.equipment)
          scope.eventsArray.push event
          @groupArr(scope,element,"eventType")
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
        @setChartsData(scope,element,att)
    # 处理图表数据
    setChartsData:(scope,element,att)=>
      scope.chartsDataArr.splice(0,scope.chartsDataArr.length)
      for type in scope.eventType
        for event in att
          if(type.model.type == event.type)
            dataValue = {name:"",value: 0}
            dataValue.name = type.model.name
            dataValue.value = @addZero(event.list.length)
            scope.chartsDataArr.push(dataValue)
      scope.eventTotal = @addZero(scope.eventsArray.length)
      @createLineCharts(scope,element)
    # 渲染图表
    createLineCharts: (scope,element) =>
      line = element.find(".echartsContent")
      scope.echart?.dispose()
      option = 
        color: ['#FD855B', '#FF6D39','#FADB00']
#        title:
#          text: '总数'
#          subtext: scope.eventTotal
#          textStyle:
#            color: '#F4F7FF'
#            fontSize: 28
#          subtextStyle:
#            fontSize: 18
#            color: ['#ff9d19']
#          x: 'center'
#          y: '40%'
        grid:
          bottom: 150
          left: 100
          top: 50
          right: '10%'
        tooltip: 
          formatter: '{b}<br /> {c}条 ({d}%)'
        legend:
          orient: 'horizontal'
#          orient: 'vertical'
          top: 'top',
          right: "4%"
          data: scope.chartsDataArr
          icon: 'pin'
          textStyle:
            color: "#F4F7FF"
            fontSize: 14
        series:[
          {
            radius: '60%'
            center: ['50%', '60%']
            type: 'pie',
            label:
              normal:
                show: true
                formatter: "{b} : {c}"
                textStyle:
                  fontSize: 14
                position: 'outside'
              emphasis:
                show: true
            labelLine:
              normal:
                show: true
            name: "设备告警总量"
            data: scope.chartsDataArr
          },
#          {
#            radius: ['40%', '44%']
#            center: ['50%', '50%']
#            type: 'pie'
#            label:
#              normal:
#                show: false
#              emphasis:
#                show: false
#            labelLine:
#              normal:
#                show: false
#              emphasis:
#                show: false
#            animation: false
#            tooltip:
#              show: false
#            data:[{
#              value: 0
#              itemStyle:
#                color: "rgba(250,250,250,0.3)"
#            }]
#          },
#          {
#            name: '外边框'
#            type: 'pie'
#            clockWise: false
#            hoverAnimation: false
#            center: ['50%', '50%']
#            radius: ['75%', '75%']
#            label:
#              normal:
#                show: false
#            data: [{
#              value: 0
#              name: ''
#              itemStyle:
#                normal:
#                  borderWidth: 1
#                  borderColor: '#004e8d'
#            }]
#          }
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
      scope.eventSubscriptionArray.forEach (sub)=>
        sub.dispose()

  exports =
    DeviceAlarmChartDirective: DeviceAlarmChartDirective