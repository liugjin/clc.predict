###
* File: bathtub-curve-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class BathtubCurveDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "bathtub-curve"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.equipSubscription = {}
      scope.signalDataArr = []
      scope.dataDeviceArr = [0,0,0,0,0,0]
      scope.dataDeviceAve = [0,0,0,0]
      scope.yearData = [moment().format('YYYY'), moment().add(1, 'years').format('YYYY'), moment().add(2, 'years').format('YYYY'),moment().add(3, 'years').format('YYYY')]
      #曲线图初始化
      myChart = element.find("#main")

      scope.echart = echarts.init myChart[0]
      option = @createOption scope
      scope.echart.setOption option
      window.onresize = scope.echart.resize
      # 封装获取设备信息号函数
      getDeviceSignal = (scope,equipment,signalID)=>
        filter =
          user: scope.project.model.user
          project: scope.project.model.project
          station: equipment.model.station
          equipment: equipment.model.equipment
          signal: signalID
        str = equipment.key + "-"+ signalID
        scope.equipSubscription[str]?.dispose()
        scope.equipSubscription[str] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
          if signal and signal.message
            value1 = Number(signal.message.value)
            if isNaN(value1)
              value1 = 0
            scope.dataDeviceAve[0] = value1.toFixed(2)
            scope.dataDeviceAve[1] = 2*scope.dataDeviceAve[0]
            scope.dataDeviceAve[2] = 2*scope.dataDeviceAve[1]
            scope.dataDeviceAve[3] = 2*scope.dataDeviceAve[2]
            option = @createOption scope
            scope.echart.setOption option
#            for data in scope.signalDataArr
#              if signalID == data.signalID
#                data.setValue = signal.message.value
#                scope.dataDeviceArr[deviceindex] = signal.message.value
#                sum = 0
#                for item in scope.dataDeviceArr
#                  sum += item
#                scope.dataDeviceAve[0] = Number(sum/scope.dataDeviceArr.length).toFixed(2)
#                scope.dataDeviceAve[1] = 2*scope.dataDeviceAve[0]
#                scope.dataDeviceAve[2] = 2*scope.dataDeviceAve[1]
#                scope.dataDeviceAve[3] = 2*scope.dataDeviceAve[2]
#                option = @createOption scope
#                scope.echart.setOption option
      getDeviceSignal(scope,scope.equipment,'device-health')
#      if scope.equipment.model.type == 'motor'
#        getDeviceSignal(scope,scope.equipment,'fall',0)
#        getDeviceSignal(scope,scope.equipment,'abrasion',1)
#        getDeviceSignal(scope,scope.equipment,'short',2)
#        getDeviceSignal(scope,scope.equipment,'loss',3)
#        getDeviceSignal(scope,scope.equipment,'fixture',4)
#        getDeviceSignal(scope,scope.equipment,'deposit',5)
#        scope.signalDataArr = [
#          {stateName:"定子线圈的绝缘老化情况",stateValue:'优秀',setValue:0,signalID:'fall'},
#          {stateName:"轴承磨损情况",stateValue:'优秀',setValue:0,signalID:'abrasion'},
#          {stateName:"转子短条预测情况",stateValue:'优秀',setValue:0,signalID:'short'},
#          {stateName:"轴承润滑油损耗情况",stateValue:'优秀',setValue:0,signalID:'loss'},
#          {stateName:"底座紧固情况",stateValue:'优秀',setValue:0,signalID:'fixture'},
#          {stateName:"风扇积灰程度",stateValue:'优秀',setValue:0,signalID:'deposit'}
#        ]
#      else if scope.equipment.model.type == 'inverter'
#        getDeviceSignal(scope,scope.equipment,'ash',0)
#        getDeviceSignal(scope,scope.equipment,'capacitance-aging',1)
#        getDeviceSignal(scope,scope.equipment,'control-board-ash',2)
#        getDeviceSignal(scope,scope.equipment,'fan-aging',3)
#        getDeviceSignal(scope,scope.equipment,'oxidation',4)
#        getDeviceSignal(scope,scope.equipment,'switch-tube',5)
#        scope.signalDataArr = [
#          {stateName:"散热器积灰程度",stateValue:'优秀',setValue:0,signalID:'ash'},
#          {stateName:"母线电容老化程度",stateValue:'优秀',setValue:0,signalID:'capacitance-aging'},
#          {stateName:"主控制板积灰程度",stateValue:'优秀',setValue:0,signalID:'control-board-ash'},
#          {stateName:"散热器风扇老化情况",stateValue:'优秀',setValue:0,signalID:'fan-aging'},
#          {stateName:"接线端子氧化程度",stateValue:'优秀',setValue:0,signalID:'oxidation'},
#          {stateName:"开关管状态",stateValue:'优秀',setValue:0,signalID:'switch-tube'}
#        ]
#      else if scope.equipment.model.type == 'transformer'
#        getDeviceSignal(scope,scope.equipment,'structure-fault',0)
#        getDeviceSignal(scope,scope.equipment,'cool-oil-fault',1)
#        getDeviceSignal(scope,scope.equipment,'coil-fault',2)
#        getDeviceSignal(scope,scope.equipment,'iron-core-fault',4)
#        getDeviceSignal(scope,scope.equipment,'high-tension-fault',5)
#        scope.signalDataArr = [
#          {stateName:"结构故障",stateValue:'优秀',setValue:0,signalID:'structure-fault'},
#          {stateName:"冷却油故障",stateValue:'优秀',setValue:0,signalID:'cool-oil-fault'},
#          {stateName:"线圈故障",stateValue:'优秀',setValue:0,signalID:'coil-fault'},
#          {stateName:"铁心故障",stateValue:'优秀',setValue:0,signalID:'iron-core-fault'},
#          {stateName:"高压套管故障",stateValue:'优秀',setValue:0,signalID:'high-tension-fault'}
#        ]
#      else
#        getDeviceSignal(scope,scope.equipment,'busbar-fault',0)
#        getDeviceSignal(scope,scope.equipment,'static-contact-fault',1)
#        getDeviceSignal(scope,scope.equipment,'earthing-switch-fault',2)
#        getDeviceSignal(scope,scope.equipment,'cable-fault',3)
#        getDeviceSignal(scope,scope.equipment,'arrester-fault',4)
#        getDeviceSignal(scope,scope.equipment,'breaker-fault',5)
#        getDeviceSignal(scope,scope.equipment,'current-transformer-fault',6)
#        scope.signalDataArr = [
#          {stateName:"母线故障",stateValue:'优秀',setValue:0,signalID:'busbar-fault'},
#          {stateName:"静触头故障",stateValue:'优秀',setValue:0,signalID:'static-contact-fault'},
#          {stateName:"接地开关故障",stateValue:'优秀',setValue:0,signalID:'earthing-switch-fault'},
#          {stateName:"电缆故障",stateValue:'优秀',setValue:0,signalID:'cable-fault'},
#          {stateName:"避雷器故障",stateValue:'优秀',setValue:0,signalID:'arrester-fault'},
#          {stateName:"断路器故障",stateValue:'优秀',setValue:0,signalID:'breaker-fault'},
#          {stateName:"电流互感器故障",stateValue:'优秀',setValue:0,signalID:'current-transformer-fault'}
#        ]


#      @waitingLayout @$timeout, myChart, =>
#        scope.echart?.dispose()
#        scope.echart = echarts.init myChart[0]
#        option = @createOption scope
#        scope.echart.setOption option
#曲线图数据

    createOption: (scope) =>
      option =
        grid:
          left:'10%'
          top: '20%'
          right:'15%'
          bottom: '10%'
        tooltip :
          trigger: 'axis',
          formatter: '{b}: {c}%'
          axisPointer:
            type: 'cross',
            label:
              backgroundColor: '#10ebf4'
        xAxis:
          name: '年份'
          nameTextStyle:
            color: '#fff'
          axisLine:
            show: true
            lineStyle:
              color:'#1b3274'
          axisLabel:
            show: true
            textStyle:
              color: '#e2edf2'
          axisTick:
            show: false
          type: 'category',
          boundaryGap: false,
          data: scope.yearData
        yAxis:
          name: '风险概率(%)'
          nameTextStyle:
            color: '#fff'
            align: 'left'
            verticalAlign: 'middle'
          axisLabel:
            show: true
            textStyle:
              color: '#e2edf2'
          axisLine:
            show: true
            lineStyle:
              color:'#1b3274'
          splitLine:
            show: false
          type: 'value'
        visualMap:
          show: false
          pieces: [{
            gt: 0,
            lte: 25,
            color: '#10ebf4'
          }, {
            gt: 25,
            lte: 50,
            color: '#0094ff'
          }, {
            gt: 50,
            lte: 75,
            color: '#f3bc0f'
          }, {
            gt: 75,
            lte: 10000,
            color: '#ff0045'
          }]
        series: [
          data: scope.dataDeviceAve,
          type: 'line'
        ]
      option
    resize: (scope)->

    dispose: (scope)->
      scope.echart?.dispose()
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    BathtubCurveDirective: BathtubCurveDirective