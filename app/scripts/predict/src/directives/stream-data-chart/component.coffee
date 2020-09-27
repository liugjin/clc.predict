###
* File: stream-data-chart-directive
* User: David
* Date: 2020/01/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class StreamDataChartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-data-chart"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.chartValues = []
#      currentEquip = null
#      currentStation = null
#      dictToName = {}
      scope.currentSignalName = "信号选择"
      if !scope.mode
        scope.mode = "now"
      scope.mychart = null
      chartelement = element.find('.stream-line')
      scope.mychart = echarts.init chartelement[0]
      currentSignal = []
      scope.allStreamsignals = []
      scope.streamSignalList = []
      scope.streamDatas = []
      scope.streamDatas1 = []
      scope.streamDatas2 = []
      scope.streamDatas3 = []
      scope.equipSubscription = {}
      subscribeTodayValue = null
      severityType = {}
      _.map(scope.project.dictionary.eventseverities.items, (d) =>
        severityType[d.model.severity] = d.model.color
      )

      # 点击事件
      scope.selectSignal = (signal, index) =>
        for item in scope.streamSignalList
          if item.signal == currentSignal[0]
            item.check = false
        currentSignal[0] = signal.signal
        scope.currentSignalName = signal.name
        scope.streamSignalList[index].check = true
        getTodayData()


      cleanData = () =>
        scope.chartValues = []
        scope.streamSignalList = []



      # 获取 设备信号存储表 今日的记录
      getTodayData = () =>
        scope.urls = []
#        filter = scope.project.getIds()
#        filter.station = scope.equipment.model.station
#        filter.equipment = scope.equipment.model.equipment
#        filter.signal = {$in:currentSignal}
#        filter.startTime = moment().format("YYYY-MM-DD 00:00:00")
#        filter.endTime = moment().format("YYYY-MM-DD 23:59:59")
        filter =
          user: scope.project.model.user
          project: scope.project.model.project
          station: scope.equipment.model.station
          equipment: scope.equipment.model.equipment
          signal: currentSignal[0]
        strId = scope.equipment.key + "-"+ currentSignal[0]

        scope.equipSubscription[strId]?.dispose()
        scope.equipSubscription[strId] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
          scope.urls = []
          if signal.message && signal.message.value
            str = signal.message.value.split(',')
            for item in str
              scope.urls.push(item)
            console.log scope.urls
            if scope.urls.length == 1
              dname = ''
              $.get(scope.urls[0],null,(data)=>
                strs = data.split("\n")
                strs.pop()
                for j in scope.streamSignalList
                  if j.signal == signal.message.signal
                    dname = j.name
                scope.streamDatas = _.map strs, (d,i)=> { index:i,name: signal.message.signal, type: "line", category: dname, key: i, value: Number(d), severity: 1 }
                createOption(scope.streamDatas)
              )
            else if scope.urls.length == 3
              dname = ''
              subname = []
              $.get(scope.urls[0],null,(data1)=>
                strs = data1.split("\n")
                strs.pop()
                for j in scope.streamSignalList
                  if j.signal == signal.message.signal
                    dname = j.name
                    subname = j.subname.split(',')
                scope.streamDatas1 = _.map strs, (d,i)=> { index:i,name: signal.message.signal + '-1', type: "line", category: subname[0], key: i, value: Number(d), severity: 1, mainname: dname}
                $.get(scope.urls[1],null,(data2)=>
                  strs = data2.split("\n")
                  strs.pop()
                  for j in scope.streamSignalList
                    if j.signal == signal.message.signal
                      dname = j.name
                  scope.streamDatas2 = _.map strs, (d,i)=> { index:i,name: signal.message.signal + '-2', type: "line", category: subname[1], key: i, value: Number(d), severity: 1, mainname: dname}
                  $.get(scope.urls[2],null,(data3)=>
                    strs = data3.split("\n")
                    strs.pop()
                    for j in scope.streamSignalList
                      if j.signal == signal.message.signal
                        dname = j.name
                    scope.streamDatas3 = _.map strs, (d,i)=> { index:i,name: signal.message.signal + '-3', type: "line", category: subname[2], key: i, value: Number(d), severity: 1, mainname: dname}
                    scope.streamDatas1 = scope.streamDatas1.concat(scope.streamDatas2)
                    scope.streamDatas = scope.streamDatas1.concat(scope.streamDatas3)
                    createOption(scope.streamDatas)
                  )
                )
              )


      # 监听 - 时间
#      scope.timeSubscribe?.dispose()
#      scope.timeSubscribe = @commonService.subscribeEventBus "equipment-time", (msg) =>
#        scope.mode = msg.message?.type
#        if msg.message?.type == "now"
#          getTodayData()
#        else
#          getHistoryData(msg.message)


      createOption = (data)=>
        values = _.sortBy(_.sortBy(data, 'index'), 'name')
        type = 'line' if !type
        legendData = _.uniq _.pluck values, 'name'
        xAxisData = _.uniq _.pluck values, 'key'
        yNameData = _.uniq _.pluck values, 'category'
        yNameData = [''] if _.isEmpty yNameData
        seriesData = []
        for value, index in legendData
          data =
            name: value
            data: _.pluck(_.where(values, {name:value, category: yNameData[index]}), 'value')
            yAxisIndex: index
          seriesData.push data
        series = [{
          name:''
          type:'line'
          symbol: "none"
          smooth:true
          data:[]
          lineStyle:
            normal:
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: '#1A45A2'
                }, {
                  offset: 1, color: '#00E7EE'
                }]
              }
        }, {
          name:''
          type:'line'
          smooth:true
          symbol: "none"
          data:[]
          lineStyle:
            normal:
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: '#90D78A'
                }, {
                  offset: 1, color: '#1CAA9E'
                }]
              }
        }, {
          name:''
          type:'line'
          smooth:true
          symbol: "none"
          data:[]
          lineStyle:
            normal:
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: '#F9722C'
                }, {
                  offset: 1, color: '#FF085C'
                }]
              }
        }]

        for d,i in seriesData
          series[i].name = yNameData[i]
          series[i].data = d.data
          if xAxisData.length < (series[i].data.length - 1)
            series[i].data.slice(0, series[i].data.length - 1)

        _legendData = _.map(legendData, (d,i) => {name:yNameData[i],icon:"image://" + @getComponentPath('image/color'+(i+1)+'.svg')})
        option =
          tooltip:
            show: true
            trigger: "axis"
            axisPointer: {
              type: 'cross'
            }
          legend:
            show: true
            orient: "horizontal"
            right: "10%"
            textStyle:
              fontSize: 14
              color: "#FFFFFF"
            data: _legendData
          toolbox:
            show: true
            right: 20
            feature:
              dataZoom:
                show: false
              dataView:
                show: false
              magicType:
                type: ['line', 'bar']
              restore:
                show: false
              saveAsImage:
                show: false
          dataZoom: [
            {
              show: true,
              realtime: true,
              type: 'slider',
              dataBackground:{
                lineStyle: {
                  width: 3
                  color: 'rgb(9,175,211)'
                }
              },
              textStyle:
                fontSize: 14
                color: "#FFFFFF"
              fillerColor:"rgba(167,183,204,0.4)",
              start: 31,
              end: 32,
              xAxisIndex: [0]
            },
            {
              type: 'inside',
              realtime: true,
              start: 31,
              end: 32,
              xAxisIndex: [0]
            }
          ],
          xAxis:[{
            show: false
            data : xAxisData
            boundaryGap: false
            nameLocation: "middle"
            axisLine:
              lineStyle:
                color: "#204BAD"

          }]
          yAxis: [{
            type : 'value'
            axisLine:
              lineStyle:
                color: "#204BAD"
            axisLabel:
              textStyle:
                color: "#A2CAF8"
            splitLine:
              lineStyle:
                color: ["#204BAD"]
          }]
          series: series.slice(0, seriesData.length)
#        if typeof scope.parameters.legend == "boolean" and !scope.parameters.legend
#          option.legend.show = false
#        if typeof scope.parameters.switch == "boolean" and !scope.parameters.switch
#          option.toolbox.show = false
        scope.mychart.clear()
        scope.mychart.setOption(option)
#     订阅当前设备的所有流式数据信号，存到scope.signalList里
      scope.equipment.loadSignals null, (err, signallists) =>
#        取出流式数据信号，以分组来区分
        for item in signallists
          if item.model.group == "stream"
            scope.allStreamsignals.push(item)
        scope.streamSignalList = _.map(scope.allStreamsignals, (d, i) -> { signal: d.model.signal, name: d.model.name, subname: d.model.desc, check: if i == 0 then true else false })
        currentSignal = [scope.streamSignalList[0].signal]
        scope.currentSignalName = scope.streamSignalList[0].name
        getTodayData()
#        if scope.mode == "now"
#          getTodayData()
#        else
#          getHistoryData()
      ,true

    resize: (scope)->
      @$timeout =>
        scope.mychart?.resize()
      ,0
    dispose: (scope)->
      scope.timeSubscribe?.dispose()
      scope.mychart?.dispose()

  exports =
    StreamDataChartDirective: StreamDataChartDirective