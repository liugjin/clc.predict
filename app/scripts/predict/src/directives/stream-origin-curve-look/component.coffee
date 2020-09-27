###
* File: stream-origin-curve-look-directive
* User: David
* Date: 2020/03/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class StreamOriginCurveLookDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-origin-curve-look"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.playFlag = false
      scope.interval1 = null
      currentSignal = scope.parameters.streamSignal
      scope.chartOpts = {}
      scope.chartDatas = {}
      scope.equipSubscription = {}
      scope.chartOpts.legends = []
      scope.chartOpts.yDatas = []

      scope.chartOpts.end = 2
      scope.chartOpts.start = 0
      scope.currentMinAndMax = [0,0]
      scope.chartOpts.title = scope.parameters.signalName + '采集数据图'
      url = scope.parameters.value

      getStreamSignalData = () =>
        if currentSignal == 's-data-7'
          scope.legendList = ['A相电流','B相电流','C相电流']
        else if currentSignal == 's-data-5' || currentSignal == 's-data-6'
          scope.legendList = ['X轴震动','Y轴震动','Z轴震动']
        else
          scope.legendList = [scope.parameters.signalName]
        scope.chartOpts.legends = scope.legendList
        scope.chartDatas.xData = []
        scope.collectTime = moment(scope.parameters.sampleTime).format("YYYY-MM-DD HH:mm:ss")
        scope.chartOpts.subtext = scope.collectTime
        scope.urls = url.split(',')
        if scope.urls.length == 1
          scope.chartDatas.yData = [[]]
          $.get(scope.urls[0],null,(data)=>

            strs = data.split("\n")
            strs.pop()
            for i,j in strs
              index = j + 1
              scope.chartDatas.xData.push(index)
              scope.chartDatas.yData[0].push(Number(i))
            scope.chartOpts.yData = scope.chartDatas.yData
            scope.chartOpts.xData = scope.chartDatas.xData
            scope.calcMinAndMax scope.chartDatas.yData
            createOption scope.chartOpts
          )
        else if scope.urls.length == 3
          scope.chartDatas.yData = [[],[],[]]
          $.get(scope.urls[0],null,(data1)=>
            strs = data1.split("\n")
            strs.pop()
            for i,j in strs
              index = j + 1
              scope.chartDatas.xData.push(index)
              scope.chartDatas.yData[0].push(Number(i))
            $.get(scope.urls[1],null,(data2)=>
              strs = data2.split("\n")
              strs.pop()
              for j in strs
                scope.chartDatas.yData[1].push(Number(j))
              $.get(scope.urls[2],null,(data3)=>
                strs = data3.split("\n")
                strs.pop()
                for k in strs
                  scope.chartDatas.yData[2].push(Number(k))
                scope.chartOpts.yData = scope.chartDatas.yData
                scope.chartOpts.xData = scope.chartDatas.xData
                scope.calcMinAndMax scope.chartDatas.yData
                createOption scope.chartOpts
              )
            )
          )

      if scope.parameters.clickFlag
      else
        scope.mychart?.dispose()
        scope.mychart = null
        chartelement = element.find('#ss-origin-chart')
        scope.mychart = echarts.init chartelement[0]
        getStreamSignalData()
      #      显示全部按钮功能函数
      scope.chartShowAll = ()=>
        clearInterval(scope.interval1)
        scope.playFlag = false
        if scope.mychart && scope.chartOpts && scope.chartDatas.xData
          scope.chartOpts.yData = scope.chartDatas.yData
          scope.reSetChartOpts(scope.chartOpts)

      scope.chartPlayPause = ()=>
        if !scope.playFlag
          if scope.mychart && scope.chartOpts && scope.chartDatas.xData
            if scope.chartOpts.yData[0].length == scope.chartDatas.xData.length
              if scope.chartOpts.legends.length == 3
                scope.chartOpts.yData = [[],[],[]]
              else
                scope.chartOpts.yData = [[]]
            scope.playFlag = true
            #         设置echart图表播放功能
            scope.interval1 = setInterval(() =>
              if scope.chartOpts.yData[0].length < scope.chartDatas.xData.length
                i =0
                while i<4
                  if scope.chartOpts.legends.length == 3
                    scope.chartOpts.yData[0].push(scope.chartDatas.yData[0][scope.chartOpts.yData[0].length])
                    scope.chartOpts.yData[1].push(scope.chartDatas.yData[1][scope.chartOpts.yData[1].length])
                    scope.chartOpts.yData[2].push(scope.chartDatas.yData[2][scope.chartOpts.yData[2].length])
                  else
                    scope.chartOpts.yData[0].push(scope.chartDatas.yData[0][scope.chartOpts.yData[0].length])
                  i++
              else
                scope.chartOpts.yData = [[]]
              scope.reSetChartOpts(scope.chartOpts)
            ,1000)
        else
          clearInterval(scope.interval1)
          scope.playFlag = false
      #        重设chart参数，更新chart数据
      scope.reSetChartOpts = (opts)=>
        series1 = []
        for item, index in opts.yData
          series1.push({
            data:item
          })
        scope.mychart.setOption {
          series:series1
        }
      scope.checkIfNumber= (val)=>
        if !isNaN(Number(val))
          return Number(val)
        else
          return 0
      scope.calcMinAndMax = (data)=>
        yDataMinAndMax = []
        newData = []
        for i,j in data
          newData.push([])
          for k in i
            newData[j].push(scope.checkIfNumber(k))
        if data.length == 3
          for item,index in newData
            yDataMinAndMax.push(Math.min.apply(Math,item),Math.max.apply(Math,item))
          scope.currentMinAndMax = [Math.min.apply(Math,yDataMinAndMax),Math.max.apply(Math,yDataMinAndMax)]
        else
          yDataMinAndMax.push(Math.min.apply(Math,newData[0]),Math.max.apply(Math,newData[0]))
          scope.currentMinAndMax = yDataMinAndMax
        scope.$applyAsync()
      createOption = (opts)=>
        colors = [['#1A45A2','#00E7EE'],['#90D78A','#1CAA9E'],['#F9722C','#FF085C']]
        series = []
        console.log opts
        for item, index in opts.yData
          series.push({
            name:opts.legends[index]
            type:'line'
            symbol: "none"
            smooth:true
            data:item
            lineStyle:
              width:2
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: colors[index][0]
                }, {
                  offset: 1, color: colors[index][1]
                }]
              }
          })
        _legendData = _.map(opts.legends, (d,i) => {name:d,icon:"image://" + @getComponentPath('image/color'+(i+1)+'.svg')})
        option =
          title:
            text: opts.title
            textStyle:
              color: '#fff'
            left: 'center'
            top: 0
            subtext: '采集时间'+opts.subtext
            subtextStyle:
              color: 'rgba(156,165,193,1)'
              fontSize: 14
          tooltip:
            show: true
            trigger: "axis"
            axisPointer: {
              type: 'cross'
            }
          legend:
            show: true
            right: '2%'
            orient: "horizontal"
            textStyle:
              fontSize: 14
              color: "#FFFFFF"
            data: _legendData
          grid:
            right: 20
          toolbox:
            show: true
            right: 20
            feature:
              dataZoom:
                show: false
              dataView:
                show: false
              magicType:
                show:false
              restore:
                show: false
              saveAsImage:
                show: false
          dataZoom: [
            {
              type: 'inside',
              realtime: true,
              start: opts.start,
              end: opts.end,
            },
            {
              show: true,
              realtime: true,
              type: 'slider',
              height: 20
              borderColor: 'rgba(2,62,116,1)'
              dataBackground:{
                lineStyle: {
                  width: 3
                  color: {
                    type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                    colorStops: [{
                      offset: 0, color: '#1A45A2'
                    }, {
                      offset: 1, color: '#00E7EE'
                    }]
                  }
                }
                areaStyle:{
                  color: {
                    type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                    colorStops: [{
                      offset: 0, color: '#1A45A2'
                    }, {
                      offset: 1, color: '#00E7EE'
                    }]
                  }
                }
              },
              handleStyle:
                color: 'rgba(0,167,255,1)'
              textStyle:
                fontSize: 14
                color: "#FFFFFF"
              fillerColor:"rgba(2,62,116,0.8)",
              bottom: 0
            }
          ],
          xAxis:
            show: false
            nameTextStyle:
              color: 'rgba(156,165,193,1)'
            data : opts.xData
            type: 'category'
            boundaryGap: false
            nameLocation: "middle"
            axisLine:
              onZero: false
              lineStyle:
                color: "#204BAD"
            axisLabel:
              show: false
              textStyle:
                color: 'rgba(156,165,193,1)'
          yAxis:
            type : 'value'
            axisLine:
              lineStyle:
                color: "#204BAD"
            axisLabel:
              textStyle:
                color: 'rgba(156,165,193,1)'
            splitLine:
              lineStyle:
                color: ["#204BAD"]
          series: series

        scope.mychart.setOption(option)

    resize: (scope)->
      @$timeout =>
        scope.mychart?.resize()
      ,0
    dispose: (scope)->
      scope.mychart?.dispose()
      scope.mychart = null
      scope.chartOpts = null
      scope.chartDatas = null
      clearInterval(scope.interval1)

  exports =
    StreamOriginCurveLookDirective: StreamOriginCurveLookDirective