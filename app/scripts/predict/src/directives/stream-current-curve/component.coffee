###
* File: stream-current-curve-directive
* User: David
* Date: 2020/03/10
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class StreamCurrentCurveDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-current-curve"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.playFlag = false
      scope.signalDataArr = []
      scope.equipSubscription = {}
      scope.submitDatas = {
        currentSignal: ''
        predictNum: 0
        predictText: ''
      }
      scope.currentLegends = []
      scope.interval1 = null
      scope.chartOpts = {
        yData1MinAndMax: [0,0]

      }
      scope.chartDatas = {
        yDatas: []
      }
      scope.chartOpts.legends = []
      scope.chartOpts.yDatas = []
      scope.chartOpts.end = 10
      scope.chartOpts.start = 0
      scope.streamLegendList = []
      scope.currentDisplayList = []
      scope.currentMinAndMax = [[0,0],[0,0]]
      scope.abcSeriesList = []
      scope.maxAndMins = {}
      scope.dataFlag = false
      scope.getStreamSignalData = ()=>
        filter =
          user: scope.project.model.user
          project: scope.project.model.project
          station: scope.equipment.model.station
          equipment: scope.equipment.model.equipment
          signal: scope.parameters.currentSignal+'-ttf'
        strId = scope.equipment.key + "-"+ filter.signal
        scope.equipSubscription[strId]?.dispose()
        scope.equipSubscription[strId] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
          if signal.message && signal.message.value
            scope.dataFlag = true
            scope.collectTime = moment(signal.message.timestamp).format("YYYY-MM-DD HH:mm:ss")
            scope.chartOpts.subtext = scope.collectTime
            scope.dataUrl = signal.message.value
#            先用ajax请求将返回的数据变为arraybuffer格式，再用XLSX转成数组
            scope.$root.loading = true
            xhr = new XMLHttpRequest()
            xhr.open('get', scope.dataUrl,true)
            xhr.responseType ='arraybuffer'
            xhr.onload = (e)=>
              if xhr.status ==200
                data =new Uint8Array(xhr.response)
                wb = XLSX.read(data, {type:'array'})
                testStr = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]])
                scope.jsonToStringData(testStr)

            xhr.send()

      if scope.parameters.streamFlag
        scope.getStreamSignalData()
      else
        scope.echart1?.dispose()
        scope.echart2?.dispose()
        scope.echart1 = null
        scope.echart2 = null
#        文件数据下载
      scope.downLoadStream = ()=>
        if scope.dataUrl
          window.open(scope.dataUrl,'_blank')
        else
          @display "暂无数据，无法下载！"
      scope.InitChartOpt = ()=>
#曲线图初始化
        myChart1 = element.find("#ss-chart1")
        myChart2 = element.find("#ss-chart2")
        scope.$root.loading = false
        scope.echart1 = echarts.init myChart1[0]
        scope.echart2 = echarts.init myChart2[0]
        option1 = @createOption scope.chartOpts,0
        option2 = @createOption scope.chartOpts,1

        scope.echart1.setOption option1
        scope.echart2.setOption option2
      scope.originalStream = ()=>
        @commonService.publishEventBus 'old-new-stream-flag','old'
        scope.$applyAsync()
        console.log scope.parameters

      scope.chartShowAll = ()=>
        clearInterval(scope.interval1)
        scope.playFlag = false
        if scope.echart1 && scope.chartOpts && scope.chartDatas.xData
          abcIndex = Number(scope.chartOpts.currentAbcSeries.index + 1)
          legendIndex = Number(scope.chartOpts.currentLegends.index)
          scope.chartOpts.yData1 = scope.chartDatas['data'+abcIndex].yData1[legendIndex]
          scope.chartOpts.yData2 = scope.chartDatas['data'+abcIndex].yData2[legendIndex]
          scope.reSetChartOpts(scope.chartOpts)

      scope.chartPlayPause = ()=>
        if !scope.playFlag
          if scope.echart1 && scope.chartOpts && scope.chartDatas.xData
            if scope.chartOpts.yData1.length == scope.chartDatas.xData.length
              scope.chartOpts.yData1 = []
              scope.chartOpts.yData2 = []
            scope.playFlag = true
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
        else
          clearInterval(scope.interval1)
          scope.playFlag = false

      scope.jsonToStringData = (data)=>

        xData = []
        scope.chartDatas.data1 =
          yData1: [[],[],[]]
          yData2: [[],[],[]]
        scope.chartDatas.data2 =
          yData1: [[],[],[]]
          yData2: [[],[],[]]
        scope.chartDatas.data3 =
          yData1: [[],[],[]]
          yData2: [[],[],[]]
        minAndMax1 =
          yData1MinAndMax: [[],[],[]]
          yData2MinAndMax: [[],[],[]]
        minAndMax2 =
          yData1MinAndMax: [[],[],[]]
          yData2MinAndMax: [[],[],[]]
        minAndMax3 =
          yData1MinAndMax: [[],[],[]]
          yData2MinAndMax: [[],[],[]]
        if Array.isArray(data)
          signal = scope.parameters.currentSignal
          scope.chartOpts.normalDatas = [[-20000000,20000000],[0,200]]
          keyData = data[0]
          for j,k of keyData
            scope.chartOpts.legends.push(j)
          if scope.chartOpts.legends.length == 21
            scope.chartOpts.legends.pop()
            scope.chartOpts.legends.splice(6,1)
            scope.chartOpts.legends.splice(12,1)
            for j in [0,1,2]
              scope.streamLegendList.push([])
              for i in[0,1,2]
                name1 = scope.chartOpts.legends[i+j*6]
                name2 = scope.chartOpts.legends[i+j*6+3]
                name = name1 + ',' + name2
                scope.streamLegendList[j].push({legend1:name1, legend2:name2,name:name,index:i,optindex:j})
          else if scope.chartOpts.legends.length == 7
            scope.chartOpts.legends.pop()
            for i in [0,1,2]
              name1 = scope.chartOpts.legends[i]
              name2 = scope.chartOpts.legends[i+3]
              name = name1 + ',' + name2
              scope.streamLegendList.push({legend1:name1, legend2:name2,name:name,index:i})
          if signal == 's-data-7'
            seriesSelect = ['A相电流','B相电流','C相电流']
          else
            seriesSelect = ['X轴震动','Y轴震动','Z轴震动']

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
          scope.chartOpts.title1 = scope.parameters.currentName + '时域图'
          scope.chartOpts.title2 = scope.parameters.currentName + '频域图'
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
        abcIndex = Number(scope.chartOpts.currentAbcSeries.index + 1)
        scope.chartOpts.currentLegends = scope.currentDisplayList[index]

        scope.chartOpts.yData1 = scope.chartDatas['data'+abcIndex].yData1[index]
        scope.chartOpts.yData2 = scope.chartDatas['data'+abcIndex].yData2[index]
        scope.currentMinAndMax[0] = scope.maxAndMins['minAndMax'+abcIndex].yData1MinAndMax[index]
        scope.currentMinAndMax[1] = scope.maxAndMins['minAndMax'+abcIndex].yData2MinAndMax[index]
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
      scope.checkIfNumber= (val)=>
        if !isNaN(Number(val))
          return Number(val)
        else
          return 0
      scope.hidemodal = ()->
        $('#stream-predict-modal').modal('close')
      scope.openModal=()->
        $('#stream-predict-modal').modal('open')
      scope.compare = ()=>
        window.location.hash = "#/stream-compare/#{scope.project.model.user}/#{scope.project.model.project}"
      scope.equipment.loadSignals null,(err,signals)=>
        if(signals)
          for sig in signals
            if(sig.model.type == scope.equipment.model.type)
              if(sig.model.template == "base-"+scope.equipment.model.type and sig.model.signal !="device-flag" and sig.model.signal !="device-health")
                signalValue = {}
                signalValue.name = sig.model.name
                signalValue.signalID = sig.model.signal
                signalValue.passId = sig.model.expression.variables[0].value
                signalValue.check = false
                scope.signalDataArr.push(signalValue)
                scope.submitDatas.currentSignal = scope.signalDataArr[0]
      scope.selectStreamSig = (type,index) =>
        scope.submitDatas.currentSignal = type
      scope.submitMessage = ()=>
        if Number(scope.submitDatas.predictNum)>100 || Number(scope.submitDatas.predictNum)<0
          @display '预测值为0~100之间!'
          return
        else
          channel2Data = {}
          channel1 = scope.submitDatas.currentSignal.passId.split('/')[1]
          channel2Data.mchannel = channel1
          channel2Data.mvalue = Number(scope.submitDatas.predictNum)
          channel2Data.editor = scope.project.model.userName
          channel2Data.signal = scope.submitDatas.currentSignal.signalID
          channel2Data.name = scope.submitDatas.currentSignal.name
          channel2Data.url = scope.dataUrl
          channel2Data.desc = scope.submitDatas.predictText
          str= Number(scope.submitDatas.predictNum)
          sus = scope.equipment.model.sampleUnits
          su = ''
          for i in sus
            if i.id == 'sustream'
              su = i.value
          $.post("manualControl",{su:su,channel1:channel1,channel1data:str,channel2:"manual-describe",channel2data:channel2Data}).then (response)=>
            console.log response
            if response.result == 1 || response.data.result == 1
              @display '信息反馈成功!'
              scope.submitDatas.predictNum = 0
              scope.submitDatas.predictText = ''
              scope.hidemodal()
            else
              @display '信息反馈失败!'

      window.addEventListener 'resize', scope.resize
#      window.addEventListener scope.parameters, scope.InitChartOpt
    createOption: (opts,index) =>
      i = Number(index + 1)
      colors = [['#1A45A2','#00E7EE'],['#90D78A','#1CAA9E'],['#F9722C','#FF085C']]
      color = ['#00E7EE','#4169E1']
      title = ['时间(ms)','频率(Hz)']
      series = {
        name: opts.currentLegends['legend'+i]
        type:'line'
        symbol: "none"
        lineStyle:
          width: 1
#          color: {
#            type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
#            colorStops: [{
#              offset: 0, color: colors[index][0]
#            }, {
#              offset: 1, color: colors[index][1]
#            }]
#          }
        smooth:true
        data:opts['yData'+i]
      }
      visualMap = [{
        top: 10,
        left: 10,
        seriesIndex:0,
        textStyle:
          color: '#fff'
#        range: [opts.normalDatas[index][0],opts.normalDatas[index][1]]
#        inRange:
#          color: '#00E7EE'
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
              color: "#fff"
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
              color: "rgba(156,165,193,1)"
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
      for key, value of scope.equipSubscription
        value?.dispose()
      scope.echart1?.dispose()
      scope.echart1 = null
      scope.echart2?.dispose()
      scope.echart2 = null
      scope.chartOpts = null
      scope.chartDatas = null
      clearInterval(scope.interval1)


  exports =
    StreamCurrentCurveDirective: StreamCurrentCurveDirective