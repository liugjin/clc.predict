###
* File: stream-shock-curve-directive
* User: David
* Date: 2020/03/10
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class StreamShockCurveDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-shock-curve"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      rABS= false
      colors = ['#FFD700','#90D78A','#1CAA9E','#F9722C','#FF085C']
      scope.playFlag = false
      scope.streamLegendList = []
      currentLegends = []
      ySeriesDatas = []
      scope.equipSubscription = {}
      scope.interval1 = null
      scope.chartOpts = {
        yData1MinAndMax: [0,0]

      }
      scope.chartDatas = {
        yDatas: []
      }
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
            scope.dataUrl = signal.message.value
            #            先用ajax请求将返回的数据变为arraybuffer格式，再用XLSX转成数组
            xhr = new XMLHttpRequest()
            xhr.open('get', scope.dataUrl,true)
            xhr.responseType ='arraybuffer'
            xhr.onload = (e)=>
              if xhr.status ==200
                data =new Uint8Array(xhr.response)
                wb = XLSX.read(data, {type:'array'})
                testStr = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]])

                scope.jsonToStringData(testStr)
                scope.InitChartOpt()
            xhr.send()
      if scope.parameters.streamFlag
#        scope.InitChartOpt()
        scope.getStreamSignalData()
      else
        scope.myChart?.dispose()
        scope.myChart = null
      scope.InitChartOpt = ()=>
#曲线图初始化
        myChart = element.find("#ss-chart")

        scope.echart = echarts.init myChart[0]
        option = @createOption scope.chartOpts
        scope.echart.setOption option

      scope.chartShowAll = ()=>
        clearInterval(scope.interval1)
        scope.playFlag = false
        if scope.echart && scope.chartOpts && scope.chartDatas.xData
          scope.chartOpts.yDatas = []
          scope.chartOpts.yDatas.push(scope.chartDatas.yDatas[0],scope.chartDatas.yDatas[1],scope.chartDatas.yDatas[2])
          currentLegends = scope.chartOpts.legends
          scope.reSetChartOpts(scope.chartOpts.yDatas)

      scope.chartPlayPause = ()=>
        if !scope.playFlag
          if scope.echart && scope.chartOpts && scope.chartDatas.xData
            if ySeriesDatas.length == 0
#            if ySeriesDatas[0].length == scope.chartDatas.xData.length
              ySeriesDatas = []
              for item,i in currentLegends
                ySeriesDatas.push([])
            scope.playFlag = true
            #         设置echart图表播放功能
            scope.interval1 = setInterval(() =>
              if ySeriesDatas[0].length < scope.chartOpts.xData.length
                i =0
                while i<2
                  for item,j in scope.chartOpts.yDatas
                    ySeriesDatas[j].push(scope.chartOpts.yDatas[j][ySeriesDatas[j].length])
                  i++
              else
                ySeriesDatas = []
                for item,i in currentLegends
                  ySeriesDatas.push([])
              console.log ySeriesDatas
              scope.reSetChartOpts(ySeriesDatas)
            ,1000)
        else
          clearInterval(scope.interval1)
          scope.playFlag = false

      scope.jsonToStringData = (data)=>
        scope.chartOpts.legends = []
        scope.chartOpts.yDatas = []
        seriesName = ['A相电流','B相电流','C相电流']
        scope.chartOpts.end = 5
        scope.chartOpts.start = 0
        if Array.isArray(data)
#          seriesName = data[0]
#          scope.chartOpts.legends.push(seriesName['__EMPTY_1'],seriesName['__EMPTY_3'],seriesName['__EMPTY_4'])
          scope.chartOpts.legends = ['RMS Data','Amplitude of FFT Data','Phase Angle']
          xData = []
          yData1 = []
          yData2 = []
          yData3 = []
          yData1MinAndMax = []
          minAndMax = []
          for item,i in data
            xData.push(i+1)
            yData1.push(scope.checkIfNumber(item['RMS Data']))
            yData2.push(scope.checkIfNumber(item['Amplitude of FFT Data']))
            yData3.push(scope.checkIfNumber(item['Phase Angle']))
          minAndMax.push(Math.min.apply(null,yData1),Math.max.apply(null,yData1))
          minAndMax.push(Math.min.apply(Math,yData2),Math.max.apply(Math,yData2))
          minAndMax.push(Math.min.apply(Math,yData3),Math.max.apply(Math,yData3))
          yData1MinAndMax.push(Math.min.apply(Math,minAndMax),Math.max.apply(Math,minAndMax))
          scope.chartOpts.yData1MinAndMax = yData1MinAndMax
          scope.chartOpts.xData = xData
          scope.chartOpts.yDatas.push(yData1,yData2,yData3)
          scope.chartOpts.title = scope.parameters.currentName + '数据分析图'
          scope.streamLegendList = _.map(scope.chartOpts.legends, (d, i) -> { legend: d, name: d, index:i,check: true })
          currentLegends = scope.chartOpts.legends
#          console.log scope.streamLegendList

          scope.chartDatas.xData =xData
          scope.chartDatas.yDatas.push(yData1,yData2,yData3)
          scope.$applyAsync()
      #          console.log scope.chartOpts
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
        if typeof val != 'number'
          return 0
        if !isNaN(val)
          return val
        else
          return 0
      scope.selectLegend = (leg, index)=>
        legendId = _.indexOf(currentLegends, leg.legend)
        if legendId is -1 and currentLegends.length < 3
          currentLegends.push(leg.legend)
        else if legendId != -1 and currentLegends.length > 1
          currentLegends = _.filter(currentLegends, (d) => d != leg.legend)
          console.log currentLegends
        else
          @display '请选择1-3个数据项!'
          return
        scope.streamLegendList[index].check = !leg.check
        scope.chartOpts.yDatas = []
        for item,i in scope.streamLegendList
          if item.check
            scope.chartOpts.yDatas.push(scope.chartDatas.yDatas[i])
        ySeriesDatas = scope.chartOpts.yDatas
        scope.reSetChartOpts(scope.chartOpts.yDatas)
      scope.reSetChartOpts = (yDatas)=>
        series = []
        visualMap = []
        for item,i in yDatas
          series.push({
            name: currentLegends[i]
            data:item
          })
          visualMap.push({
            pieces: [{
              gt: 0,
              lte: 100,
              color: colors[i%colors.length]
            }]
            seriesIndex: i
            outOfRange:
              color: 'red'
          })
        scope.echart.setOption {
          series:[{data:null},{data:null},{data:null}]
        }
        scope.echart.setOption {
          legend:
            data: currentLegends
          visualMap: visualMap
          series:series
        }
      scope.hidemodal = ()->
        $('#stream-predict-modal').modal('close')
      scope.openModal=()->
        $('#stream-predict-modal').modal('open')
      scope.resize=()=>
        @$timeout =>
          scope.myChart?.resize()
        ,100
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
              if(sig.model.template == "base-"+scope.equipment.model.type and sig.model.signal !="device-flag")
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
          console.log scope
          channel1 = scope.submitDatas.currentSignal.passId.split('/')[1]
          channel2Data.mchannel = channel1
          channel2Data.mvalue = Number(scope.submitDatas.predictNum)
          channel2Data.editor = scope.project.model.userName
          channel2Data.psignal = scope.submitDatas.currentSignal.signalID
          channel2Data.url = scope.dataUrl
          channel2Data.desc = scope.submitDatas.predictText
#          str= "'" +Number(scope.submitDatas.predictNum)+ "'"
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
    createOption: (opts) =>
      colors = ['#FFD700','#90D78A','#1CAA9E','#F9722C','#FF085C']
      series = []
      visualMap = []
      for item,index in opts.yDatas
        series.push({
          name: opts.legends[index]
          type:'line'
          symbol: "none"
          lineStyle:
            width: 2
          smooth:true
          data:item
        })
        visualMap.push({
          top: 20,
          right: 10,
          textStyle:
            color: '#fff'
          pieces: [{
            gt: 0,
            lte: 100,
            color: colors[index%colors.length]
          }]
          seriesIndex: index
          outOfRange:
            color: 'red'
        })
      option =
        animation: false
        title:
          text: opts.title
          textStyle:
            color: '#fff'
          left: 'center'
          top: 0
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
          data: opts.legends
        toolbox:
          show: true
          right: 0
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
        visualMap: visualMap
        dataZoom: [
          {
            type: 'inside',
            realtime: true,
            start: opts.start,
            end: opts.end,
            xAxisIndex: [0]
          },
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

            bottom: 0
            xAxisIndex: [0]
          }

        ],
        xAxis:[{
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
        }]
        yAxis: [{
          name: '震动数据'
          type : 'value'
          axisLine:
            lineStyle:
              color: "#204BAD"
          axisLabel:
            textStyle:
              color: "#fff"
          splitLine:
            show:false
        }]
        series: series
      option
    resize: (scope)->
      scope.myChart?.resize()
    dispose: (scope)->
      scope.myChart?.dispose()
      for key, value of scope.equipSubscription
        value?.dispose()
      scope.myChart = null
      scope.chartOpts = null
      scope.chartDatas = null
      clearInterval(scope.interval1)

  exports =
    StreamShockCurveDirective: StreamShockCurveDirective