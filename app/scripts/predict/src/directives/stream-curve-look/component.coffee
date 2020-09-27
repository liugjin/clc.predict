###
* File: stream-curve-look-directive
* User: David
* Date: 2020/03/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class StreamCurveLookDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-curve-look"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.playFlag = false
      scope.streamLegendList = []
      scope.signalDataArr = []
      scope.equipSubscription = {}
      scope.currentLegends = []
      scope.interval1 = null
      console.log scope.parameters
      scope.chartOpts = {
        yData1MinAndMax: [0,0]
        title1: scope.parameters.signalName + '时域图'
        title2: scope.parameters.signalName + '频域图'
      }
      scope.chartDatas = {
        yDatas: []
      }
#      此变量用于控制文件里读到的数据是1组还是3组
      scope.dataNumFlag = 1
      scope.chartOpts.legends = []
      scope.chartOpts.yDatas = []
      scope.chartOpts.end = 10
      scope.chartOpts.start = 0
      scope.streamLegendList = []
      scope.currentDisplayList = []
      scope.currentMinAndMax = [[0,0],[0,0]]
      scope.abcSeriesList = []
      scope.maxAndMins = {}
      scope.collectTime = moment(scope.parameters.sampleTime).format("YYYY-MM-DD HH:mm:ss")
      scope.chartOpts.subtext = scope.collectTime
      scope.getStreamSignalData = ()=>
        scope.dataUrl = scope.parameters.value
        #            先用ajax请求将返回的数据变为arraybuffer格式，再用XLSX转成数组
        xhr = new XMLHttpRequest()
        xhr.open('get', scope.dataUrl,true)
        xhr.responseType ='arraybuffer'
        xhr.onload = (e)=>
          scope.$root.loading = true
          if xhr.status ==200
            data =new Uint8Array(xhr.response)
            wb = XLSX.read(data, {type:'array'})
            testStr = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]])
            scope.jsonToStringData(testStr)
        xhr.send()

      scope.jsonToStringData = (data)=>
        if Array.isArray(data)
          scope.chartOpts.normalDatas = [[-20000000,20000000],[0,200]]
          keyData = data[0]
          for j,k of keyData
            scope.chartOpts.legends.push(j)
          if scope.chartOpts.legends.length == 21
            scope.chartOpts.legends.pop()
            scope.chartDatas.data1 =
              yData1: [[],[],[]]
              yData2: [[],[],[]]
            scope.chartDatas.data2 =
              yData1: [[],[],[]]
              yData2: [[],[],[]]
            scope.chartDatas.data3 =
              yData1: [[],[],[]]
              yData2: [[],[],[]]
            scope.chartOpts.legends.splice(6,1)
            scope.chartOpts.legends.splice(12,1)
            scope.dataNumFlag = 3
            for j in [0,1,2]
              scope.streamLegendList.push([])
              for i in[0,1,2]
                name1 = scope.chartOpts.legends[i+j*6]
                name2 = scope.chartOpts.legends[i+j*6+3]
                name = name1 + ',' + name2
                scope.streamLegendList[j].push({legend1:name1, legend2:name2,name:name,index:i,optindex:j})
            scope.dataAnalysis3(data)
          else if scope.chartOpts.legends.length == 7
            scope.chartOpts.legends.pop()
            scope.chartDatas.yData1 = [[],[],[]]
            scope.chartDatas.yData2 = [[],[],[]]
            scope.dataNumFlag = 1
            for i in [0,1,2]
              name1 = scope.chartOpts.legends[i]
              name2 = scope.chartOpts.legends[i+3]
              name = name1 + ',' + name2
              scope.streamLegendList.push({legend1:name1, legend2:name2,name:name,index:i})
            scope.dataAnalysis1(data)
      if scope.parameters.clickFlag
      else
        scope.echart1?.dispose()
        scope.echart1 = null
        scope.echart2?.dispose()
        scope.echart2 = null
        scope.getStreamSignalData()
      scope.dataAnalysis1 = (data)=>
        xData= []
        yData1MinAndMax = [[],[],[]]
        yData2MinAndMax = [[],[],[]]
        scope.chartOpts.normalDatas = [[-20000000,20000000],[0,50]]
        for item,i in data
          xData.push(i+1)
          scope.chartDatas.yData1[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[0]]))
          scope.chartDatas.yData1[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[1]]))
          scope.chartDatas.yData1[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[2]]))
          scope.chartDatas.yData2[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[3]]))
          scope.chartDatas.yData2[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[4]]))
          scope.chartDatas.yData2[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[5]]))

        scope.chartOpts.xData = xData
        scope.chartOpts.yData1 = scope.chartDatas.yData1[0]
        scope.chartOpts.yData2 = scope.chartDatas.yData2[0]
        scope.chartOpts.currentLegends = scope.streamLegendList[0]
        scope.currentDisplayList = scope.streamLegendList
        scope.chartDatas.xData = xData
        scope.InitChartOpt()
        yData1MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.yData1[0]),Math.max.apply(Math,scope.chartDatas.yData1[0]))
        yData1MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.yData1[1]),Math.max.apply(Math,scope.chartDatas.yData1[1]))
        yData1MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.yData1[2]),Math.max.apply(Math,scope.chartDatas.yData1[2]))
        yData2MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.yData2[0]),Math.max.apply(Math,scope.chartDatas.yData2[0]))
        yData2MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.yData2[1]),Math.max.apply(Math,scope.chartDatas.yData2[1]))
        yData2MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.yData2[2]),Math.max.apply(Math,scope.chartDatas.yData2[2]))
        scope.maxAndMins.yData1MinAndMax = yData1MinAndMax
        scope.maxAndMins.yData2MinAndMax = yData2MinAndMax
        scope.currentMinAndMax[0] = yData1MinAndMax[0]
        scope.currentMinAndMax[1] = yData2MinAndMax[0]
        scope.$applyAsync()
      scope.dataAnalysis3 = (data)=>
        xData = []
        signal = scope.parameters.streamSignal
        if signal == 's-data-7-ttf'
          seriesSelect = ['A相电流','B相电流','C相电流']
        else
          seriesSelect = ['X轴震动','Y轴震动','Z轴震动']
        minAndMax1 =
          yData1MinAndMax: [[],[],[]]
          yData2MinAndMax: [[],[],[]]
        minAndMax2 =
          yData1MinAndMax: [[],[],[]]
          yData2MinAndMax: [[],[],[]]
        minAndMax3 =
          yData1MinAndMax: [[],[],[]]
          yData2MinAndMax: [[],[],[]]
        scope.abcSeriesList = _.map(seriesSelect, (d, i) -> { legend: d, name: d, index:i})
        scope.currentDisplayList = scope.streamLegendList[0]
        scope.chartOpts.currentAbcSeries = scope.abcSeriesList[0]
        scope.chartOpts.currentLegends = scope.currentDisplayList[0]
        for item,i in data
          xData.push(i+1)
          scope.chartDatas.data1.yData1[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[0]]))
          scope.chartDatas.data1.yData1[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[1]]))
          scope.chartDatas.data1.yData1[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[2]]))
          scope.chartDatas.data1.yData2[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[3]]))
          scope.chartDatas.data1.yData2[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[4]]))
          scope.chartDatas.data1.yData2[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[5]]))
          scope.chartDatas.data2.yData1[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[6]]))
          scope.chartDatas.data2.yData1[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[7]]))
          scope.chartDatas.data2.yData1[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[8]]))
          scope.chartDatas.data2.yData2[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[9]]))
          scope.chartDatas.data2.yData2[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[10]]))
          scope.chartDatas.data2.yData2[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[11]]))
          scope.chartDatas.data3.yData1[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[12]]))
          scope.chartDatas.data3.yData1[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[13]]))
          scope.chartDatas.data3.yData1[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[14]]))
          scope.chartDatas.data3.yData2[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[15]]))
          scope.chartDatas.data3.yData2[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[16]]))
          scope.chartDatas.data3.yData2[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[17]]))

        scope.chartOpts.xData = xData
        scope.chartOpts.yData1 = scope.chartDatas.data1.yData1[0]
        scope.chartOpts.yData2 = scope.chartDatas.data1.yData2[0]
        scope.chartDatas.xData = xData
        scope.InitChartOpt()

        minAndMax1.yData1MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.data1.yData1[0]),Math.max.apply(Math,scope.chartDatas.data1.yData1[0]))
        minAndMax1.yData1MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.data1.yData1[1]),Math.max.apply(Math,scope.chartDatas.data1.yData1[1]))
        minAndMax1.yData1MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.data1.yData1[2]),Math.max.apply(Math,scope.chartDatas.data1.yData1[2]))
        minAndMax1.yData2MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.data1.yData2[0]),Math.max.apply(Math,scope.chartDatas.data1.yData2[0]))
        minAndMax1.yData2MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.data1.yData2[1]),Math.max.apply(Math,scope.chartDatas.data1.yData2[1]))
        minAndMax1.yData2MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.data1.yData2[2]),Math.max.apply(Math,scope.chartDatas.data1.yData2[2]))
        minAndMax2.yData1MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.data2.yData1[0]),Math.max.apply(Math,scope.chartDatas.data2.yData1[0]))
        minAndMax2.yData1MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.data2.yData1[1]),Math.max.apply(Math,scope.chartDatas.data2.yData1[1]))
        minAndMax2.yData1MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.data2.yData1[2]),Math.max.apply(Math,scope.chartDatas.data2.yData1[2]))
        minAndMax2.yData2MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.data2.yData2[0]),Math.max.apply(Math,scope.chartDatas.data2.yData2[0]))
        minAndMax2.yData2MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.data2.yData2[1]),Math.max.apply(Math,scope.chartDatas.data2.yData2[1]))
        minAndMax2.yData2MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.data2.yData2[2]),Math.max.apply(Math,scope.chartDatas.data2.yData2[2]))
        minAndMax3.yData1MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.data3.yData1[0]),Math.max.apply(Math,scope.chartDatas.data3.yData1[0]))
        minAndMax3.yData1MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.data3.yData1[1]),Math.max.apply(Math,scope.chartDatas.data3.yData1[1]))
        minAndMax3.yData1MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.data3.yData1[2]),Math.max.apply(Math,scope.chartDatas.data3.yData1[2]))
        minAndMax3.yData2MinAndMax[0].push(Math.min.apply(Math,scope.chartDatas.data3.yData2[0]),Math.max.apply(Math,scope.chartDatas.data3.yData2[0]))
        minAndMax3.yData2MinAndMax[1].push(Math.min.apply(Math,scope.chartDatas.data3.yData2[1]),Math.max.apply(Math,scope.chartDatas.data3.yData2[1]))
        minAndMax3.yData2MinAndMax[2].push(Math.min.apply(Math,scope.chartDatas.data3.yData2[2]),Math.max.apply(Math,scope.chartDatas.data3.yData2[2]))

        scope.maxAndMins.minAndMax1 = minAndMax1
        scope.maxAndMins.minAndMax2 = minAndMax2
        scope.maxAndMins.minAndMax3 = minAndMax3
        scope.currentMinAndMax[0] = minAndMax1.yData1MinAndMax[0]
        scope.currentMinAndMax[1] = minAndMax1.yData2MinAndMax[0]
        scope.$applyAsync()
      #曲线图初始化
      scope.InitChartOpt = ()=>
        myChart1 = element.find("#ss-chart1")
        myChart2 = element.find("#ss-chart2")

        scope.echart1 = echarts.init myChart1[0]
        scope.echart2 = echarts.init myChart2[0]
        option1 = @createOption scope.chartOpts,0
        option2 = @createOption scope.chartOpts,1
        scope.$root.loading = false
        scope.echart1.setOption option1
        scope.echart2.setOption option2
      scope.checkIfNumber= (val)=>
        if !isNaN(Number(val))
          return Number(val)
        else
          return 0
      scope.chartShowAll = ()=>
        clearInterval(scope.interval1)
        scope.playFlag = false
        if scope.echart1 && scope.chartOpts && scope.chartDatas.xData
          if scope.dataNumFlag == 3
            abcIndex = Number(scope.chartOpts.currentAbcSeries.index + 1)
            legendIndex = Number(scope.chartOpts.currentLegends.index)
            scope.chartOpts.yData1 = scope.chartDatas['data'+abcIndex].yData1[legendIndex]
            scope.chartOpts.yData2 = scope.chartDatas['data'+abcIndex].yData2[legendIndex]
          else if scope.dataNumFlag == 1
            index = scope.chartOpts.currentLegends.index
            scope.chartOpts.yData1 = scope.chartDatas.yData1[index]
            scope.chartOpts.yData2 = scope.chartDatas.yData2[index]
          scope.reSetChartOpts(scope.chartOpts)

      scope.chartPlayPause = ()=>
        if !scope.playFlag
          if scope.echart1 && scope.chartOpts && scope.chartDatas.xData
            if scope.chartOpts.yData1.length == scope.chartDatas.xData.length
              scope.chartOpts.yData1 = []
              scope.chartOpts.yData2 = []
              scope.playFlag = true
            if scope.dataNumFlag == 3
              #         设置echart图表播放功能
              abcIndex = Number(scope.chartOpts.currentAbcSeries.index + 1)
              legendIndex = Number(scope.chartOpts.currentLegends.index)
              scope.interval1 = setInterval(() =>
                if scope.chartOpts.yData1.length < scope.chartDatas.xData.length
                  i =0
                  while i<2
                    scope.chartOpts.yData1.push(scope.chartDatas['data'+abcIndex].yData1[legendIndex][scope.chartOpts.yData1.length])
                    scope.chartOpts.yData2.push(scope.chartDatas['data'+abcIndex].yData2[legendIndex][scope.chartOpts.yData2.length])
                    i++
                else
                  scope.chartOpts.yData1 = []
                  scope.chartOpts.yData2 = []
                scope.reSetChartOpts(scope.chartOpts)
              ,1000)
            else if scope.dataNumFlag == 1
            #         设置echart图表播放功能
              index = scope.chartOpts.currentLegends.index
              scope.interval1 = setInterval(() =>
                if scope.chartOpts.yData1.length < scope.chartDatas.xData.length
                  i =0
                  while i<2
                    scope.chartOpts.yData1.push(scope.chartDatas.yData1[index][scope.chartOpts.yData1.length])
                    scope.chartOpts.yData2.push(scope.chartDatas.yData2[index][scope.chartOpts.yData2.length])
                    i++
                else
                  scope.chartOpts.yData1 = []
                  scope.chartOpts.yData2 = []
                scope.reSetChartOpts(scope.chartOpts)
              ,1000)
        else
          clearInterval(scope.interval1)
          scope.playFlag = false
      scope.selectSeriesData = (abc, index)=>
        clearInterval(scope.interval1)
        legendIndex = Number(scope.chartOpts.currentLegends.index)
        abcIndex = Number(index + 1)
        scope.currentDisplayList = scope.streamLegendList[index]
        scope.chartOpts.currentAbcSeries = scope.abcSeriesList[index]
        scope.chartOpts.currentLegends = scope.currentDisplayList[legendIndex]
        scope.chartOpts.yData1 = scope.chartDatas['data'+abcIndex].yData1[legendIndex]
        scope.chartOpts.yData2 = scope.chartDatas['data'+abcIndex].yData2[legendIndex]
        scope.currentMinAndMax[0] = scope.maxAndMins['minAndMax'+abcIndex].yData1MinAndMax[legendIndex]
        scope.currentMinAndMax[1] = scope.maxAndMins['minAndMax'+abcIndex].yData2MinAndMax[legendIndex]
        scope.reSetChartOpts(scope.chartOpts)
      scope.selectLegend = (leg, index)=>
        clearInterval(scope.interval1)
        if scope.dataNumFlag == 3
          abcIndex = Number(scope.chartOpts.currentAbcSeries.index + 1)
          scope.chartOpts.currentLegends = scope.currentDisplayList[index]
          scope.chartOpts.yData1 = scope.chartDatas['data'+abcIndex].yData1[index]
          scope.chartOpts.yData2 = scope.chartDatas['data'+abcIndex].yData2[index]
          scope.currentMinAndMax[0] = scope.maxAndMins['minAndMax'+abcIndex].yData1MinAndMax[index]
          scope.currentMinAndMax[1] = scope.maxAndMins['minAndMax'+abcIndex].yData2MinAndMax[index]
        else if scope.dataNumFlag == 1
          scope.chartOpts.currentLegends = scope.streamLegendList[index]
          scope.chartOpts.yData1 = scope.chartDatas.yData1[index]
          scope.chartOpts.yData2 = scope.chartDatas.yData2[index]
          scope.currentMinAndMax[0] = scope.maxAndMins.yData1MinAndMax[index]
          scope.currentMinAndMax[1] = scope.maxAndMins.yData2MinAndMax[index]
        scope.reSetChartOpts(scope.chartOpts)
      scope.reSetChartOpts = (opts)=>
        series1 = []
        series2 = []
        legend1 = opts.currentLegends.legend1
        legend2 = opts.currentLegends.legend2
        series1.push({
          name: legend1
          data:opts.yData1
        })
        series2.push({
          name: legend2
          data:opts.yData2
        })

        scope.echart1.setOption {
          legend:
            data: legend1
          series:series1
        }
        scope.echart2.setOption {
          legend:
            data: legend2
          series:series2
        }
      scope.fullscreen = (element) ->
        if not element
          return
        if typeof element is 'string'
          el = angular.element element
          element = el[0]

        exit = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement
        if exit
          if document.exitFullscreen
            document.exitFullscreen()
          else if document.webkitExitFullscreen
            document.webkitExitFullscreen Element.ALLOW_KEYBOARD_INPUT
          else if document.mozExitFullScreen
            document.mozExitFullScreen()
          else if document.msExitFullscreen
            document.msExitFullscreen()
        else
          if element.requestFullscreen
            element.requestFullscreen()
          else if element.webkitRequestFullscreen
            element.webkitRequestFullscreen Element.ALLOW_KEYBOARD_INPUT
          else if element.mozRequestFullScreen
            element.mozRequestFullScreen()
          else if element.msRequestFullscreen
            element.msRequestFullscreen()
    createOption: (opts,index) =>
      i = Number(index + 1)
      color = ['#00E7EE','#4169E1']
      title = ['时间(ms)','频率(Hz)']
      series = {
        name: opts.currentLegends['legend'+i]
        type:'line'
        symbol: "none"
        lineStyle:
          width: 1
        smooth:true
        data:opts['yData'+i]
      }
      visualMap = [{
        top: 10,
        left: 10,
        seriesIndex:0,
        textStyle:
          color: '#fff'
        pieces: [{
          gt: opts.normalDatas[index][0],
          lte: opts.normalDatas[index][1],
          color: color[index]
        }]
        outOfRange:
          color: 'red'
      }]
      option =
        title:
          text: opts['title'+i]
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
          orient: "horizontal"
          bottom: 30
          textStyle:
            fontSize: 14
            color: "#FFFFFF"
          data: opts.currentLegends['legend'+i]
        grid:
          right: 5
        toolbox:
          show: true
          right: 0
          feature:
            dataZoom:
              show: false
            dataView:
              show: false
            magicType:
              show: false
              type: ['line', 'bar']
            restore:
              show: false
            saveAsImage:
              show: false
        visualMap: visualMap
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
            height: 20,
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
              },
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
          name: title[index]
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
          name: '振幅(g)'
          nameLocation: 'middle'
          nameTextStyle:
            color: 'rgba(156,165,193,1)'
            fontSize: 14
            padding: [0,0,130,0]
            align: 'left'
            verticalAlign: 'middle'
          type : 'value'
          axisLine:
            lineStyle:
              color: "#204BAD"
          axisLabel:
            textStyle:
              color: 'rgba(156,165,193,1)'
          splitLine:
            show:false
        series: series
      option
    resize: (scope)->
      @$timeout =>
        scope.echart1?.resize()
        scope.echart2?.resize()
      ,0
    dispose: (scope)->
      scope.echart1?.dispose()
      scope.echart1 = null
      scope.echart2?.dispose()
      scope.echart2 = null
      scope.chartOpts = null
      scope.chartDatas = null
      clearInterval(scope.interval1)


  exports =
    StreamCurveLookDirective: StreamCurveLookDirective