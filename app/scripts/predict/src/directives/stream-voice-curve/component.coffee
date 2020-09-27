###
* File: stream-voice-curve-directive
* User: David
* Date: 2020/03/05
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['jquery','../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], ($,base, css, view, _, moment,echarts) ->
  class StreamVoiceCurveDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-voice-curve"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.playFlag = false
      scope.interval1 = null
      scope.equipSubscription = {}
      scope.chartOpts = {}
      scope.chartDatas = {}
      scope.chartOpts.legends = []
      scope.chartOpts.yDatas = []
      scope.chartOpts.end = 10
      scope.chartOpts.start = 0
      scope.streamLegendList = []
      scope.currentMinAndMax = [[0,0],[0,0]]
      scope.maxAndMins = {}
      scope.chartOpts.legends=[]
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
            console.log signal
            scope.collectTime = moment(signal.message.timestamp).format("YYYY-MM-DD HH:mm:ss")
            scope.dataFlag = true
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
#                scope.InitChartOpt()
            xhr.send()
      if scope.parameters.streamFlag
        scope.getStreamSignalData()
      else
        scope.echart1?.dispose()
        scope.echart1 = null
        scope.echart2?.dispose()
        scope.echart2 = null
      scope.InitChartOpt = ()=>
        #曲线图初始化
        myChart1 = element.find("#ss-chart1")
        myChart2 = element.find("#ss-chart2")

        scope.echart1 = echarts.init myChart1[0]
        scope.echart2 = echarts.init myChart2[0]
        option1 = @createOption scope.chartOpts,0
        option2 = @createOption scope.chartOpts,1
        scope.$root.loading = false
        scope.echart1.setOption option1
        scope.echart2.setOption option2

#      setInterval(() =>
#        if scope.chartOpts.end < 100
#          scope.echart?.setOption({
#              dataZoom: {
#                start: scope.chartOpts.start++,
#                end: scope.chartOpts.end++
#              }
#          })
#        else
#          scope.chartOpts.start = 0
#          scope.chartOpts.end = 5
#      ,3000)

#      scope.stopPop = ()=>
#        window.event?.cancelBubble = true
      scope.originalStream = ()=>
        @commonService.publishEventBus 'old-new-stream-flag','old'
        scope.$applyAsync()
#     文件数据下载功能
      scope.downLoadStream = ()=>
        if scope.dataUrl
          window.open(scope.dataUrl,'_blank')
        else
          @display "暂无数据，无法下载！"
#      显示全部按钮功能函数
      scope.chartShowAll = ()=>
        clearInterval(scope.interval1)
        scope.playFlag = false
        if scope.echart1 && scope.chartOpts && scope.chartDatas.xData
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
#          选择数据函数，因为时域与频域数据均分为三组数据，一次仅显示一组
      scope.selectSeriesData = (leg, index)=>
        clearInterval(scope.interval1)
        scope.chartOpts.currentLegends = scope.streamLegendList[index]
        scope.chartOpts.yData1 = scope.chartDatas.yData1[index]
        scope.chartOpts.yData2 = scope.chartDatas.yData2[index]
        scope.currentMinAndMax[0] = scope.maxAndMins.yData1MinAndMax[index]
        scope.currentMinAndMax[1] = scope.maxAndMins.yData2MinAndMax[index]
        scope.reSetChartOpts(scope.chartOpts)
#        重设chart参数，更新chart数据
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
# 处理读取到的文件数据
      scope.jsonToStringData = (data)=>
        if Array.isArray(data)
          xData = []
          scope.chartDatas.yData1 = [[],[],[]]
          scope.chartDatas.yData2 = [[],[],[]]
          yData1MinAndMax = [[],[],[]]
          yData2MinAndMax = [[],[],[]]
          scope.chartOpts.normalDatas = [[-20000000,20000000],[0,50]]
          scope.chartOpts.subtext = scope.collectTime
          keyData = data[0]
          for j,k of keyData
            scope.chartOpts.legends.push(j)
          scope.chartOpts.legends.pop()

          console.log scope.chartOpts.legends
          for item,i in data
            xData.push(i+1)
            scope.chartDatas.yData1[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[0]]))
            scope.chartDatas.yData1[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[1]]))
            scope.chartDatas.yData1[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[2]]))
            scope.chartDatas.yData2[0].push(scope.checkIfNumber(item[scope.chartOpts.legends[3]]))
            scope.chartDatas.yData2[1].push(scope.checkIfNumber(item[scope.chartOpts.legends[4]]))
            scope.chartDatas.yData2[2].push(scope.checkIfNumber(item[scope.chartOpts.legends[5]]))

          scope.chartOpts.xData = xData
          scope.chartOpts.title1 = scope.parameters.currentName + '时域图'
          scope.chartOpts.title2 = scope.parameters.currentName + '频域图'
          scope.chartOpts.yData1 = scope.chartDatas.yData1[0]
          scope.chartOpts.yData2 = scope.chartDatas.yData2[0]
#          scope.streamLegendList = _.map(scope.chartOpts.legends, (d, i) -> { legend: d, name: d, index:i,check: true })
          for i in [0,1,2]
            name1 = scope.chartOpts.legends[i]
            name2 = scope.chartOpts.legends[i+3]
            name = name1 + ',' + name2
            scope.streamLegendList.push({legend1:name1, legend2:name2,name:name,index:i})
          scope.chartOpts.currentLegends = scope.streamLegendList[0]
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

#        return scope.chartOpts
      scope.checkIfNumber= (val)=>
        if !isNaN(Number(val))
          return Number(val)
        else
          return 0
      scope.hidemodal = ()->
        $('#stream-predict-modal').modal('close')

      scope.openModal=()->
        $('#stream-predict-modal').modal('open')

      scope.signalDataArr = []
      scope.submitDatas = {
        currentSignal: ''
        predictNum: 0
        predictText: ''
      }
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
      scope.compare = ()=>
        window.location.hash = "#/stream-compare/#{scope.project.model.user}/#{scope.project.model.project}"
      scope.submitMessage = ()=>
        if Number(scope.submitDatas.predictNum)>100 || Number(scope.submitDatas.predictNum)<0
          @display '预测值为0~100之间!'
          return
        else
          channel2Data = {}
          console.log scope
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
      #        全屏显示函数
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
            left: 'right'
            align: 'right'
            verticalAlign: 'top'
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
              lineStyle:
                width: 3
                color: 'rgba(0,167,255,1)'
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
      scope.echart1?.dispose()
      scope.echart1 = null
      scope.echart2?.dispose()
      scope.echart2 = null
      scope.chartOpts = null
      scope.chartDatas = null
      clearInterval(scope.interval1)


  exports =
    StreamVoiceCurveDirective: StreamVoiceCurveDirective