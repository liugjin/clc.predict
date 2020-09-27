###
* File: opc-curve-directive
* User: sheen
* Date: 2020/2/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts", 'rx', 'clc.foundation.angular/filters/format-string-filter'], (base, css, view, _, moment, echarts, Rx, fsf) ->
  class OpcCurveDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "opc-curve"

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      # 实时信号曲线 查询8个历史记录 后面订阅到的数据push到8个数据后面 展示到图表上（订阅到的第一个数据时间可能在8个历史记录时间之前）
      # 电流-温度1-电流  重复订阅问题bug
      $scope.myChart?.clear()
      $scope.$root.loading = true
      getPeriod = (mode='day') ->
        switch mode
          when 'now'
            startTime = moment().subtract 10, 'minutes'
            endTime = moment()
          else
            startTime = moment().subtract 10, 'minutes'
            endTime = moment()
        $scope.period =
          startTime: startTime
          endTime: endTime
          mode: mode


      formatString = fsf.FormatStringFilter()
      e = element.find('.ss-chart')
      $scope.mode = 'now'
      $scope.myChart = null
      $scope.signals = []
      $scope.selectSignals = []
      option = null
      series = []
      maxPoints = 20
      $scope.period = getPeriod $scope.mode
      $scope.formatStartTime = moment($scope.period.startTime).format('YYYY-MM-DD')
      $scope.opcSignalSubscription = {}
      $scope.subCount = 0
      $scope.rxSubscribe = null

      waitingLayout = ($timeout, element, callback) =>
        $timeout ->
          if element.width() <= 100
            waitingLayout $timeout, element, callback
          else
            callback()
        , 200

      # chart container is created dynamically so that render the chart until the layout is completed after the container is visible
      waitingLayout @$timeout, e, ()=>
        renderChart e

      # 初始化图表
      renderChart = (element) =>
        $scope.myChart?.dispose()
        $scope.myChart = null
        $scope.myChart = echarts.init(element[0])

      @subscribeEventBus 'stationId', (d)=>
        @getStation $scope, d.message.stationId

      @subscribeEventBus 'equipmentId', (d)=>
        @getEquipment $scope, d.message.equipmentId


      $scope.$watch 'station', (station)=>
#console.log station
        return if not station

      $scope.$watch 'equipment', (equipment)=>
#        首页第一次加载的时候 可以加载出来，进其它页面再回到首页曲线不出来 是因为从其它页面到首页equipment加载比较快，数据查询到了但是echarts还没有初始化完成，这里加一个1秒的定时解决此问题。
#console.log equipment
        return if not equipment
        setTimeout ()->
          getSignals()
        ,1000

      getSignals = ()=>
        $scope.signals = []
        $scope.selectSignals = []
        $scope.equipment.loadSignals null, (err, signals)=>
          getSingleProperty()

      getSingleProperty = ()=>
        @getProperty $scope, '_opcsignals', ()=>
          return if not $scope.property
          setSignalData()
        , true

      setSignalData = ()=>
        signals = []
        _signals2 = JSON.parse($scope.property.value)
        for s in _signals2
          item = _.find $scope.equipment.signals.items, (item) -> item.model.signal is s.signal
          signals.push item if item
        $scope.signals = signals
        if not ($scope.selectSignals.length)
          $scope.selectSignals = _.filter $scope.signals, (item)-> return item.model.signal in $scope.parameters.signalIds
#        $scope.$applyAsync()
        $scope.selectStatisticMode $scope.mode


      $scope.selectStatisticMode = (mode, period) =>
        $scope.mode = mode
        $scope.period.mode = $scope.mode
        queryStatisticRecords $scope.selectSignals, $scope.mode, period, (err, records) ->
#          console.log 'queryStatisticRecords',records
          $scope.myChart?.clear()
          option = createOption null, $scope.selectSignals, records
          $scope.$root.loading = false
          $scope.myChart?.setOption option,true
          series = option.series


      $scope.subscribeSignal = (signal) =>
        $scope.opcSignalSubscription[signal.model.signal]?.dispose()
        $scope.opcSignalSubscription[signal.model.signal] = @commonService.subscribeSignalValue signal, (d)=>
          $scope.subCount++   # 订阅到的数据不能直接放到 查询的8条历史数据后面，第一条订阅的数据可能为老的数据。
          if $scope.mode is 'now'
            addPointToSerie signal, d.data
#            console.log series
            $scope.myChart?.setOption
              series: series

      addPointToSerie = (signal, data) =>
#        console.log '增加点',data
        serie = _.find series, (s) -> s.name is signal.model.name
        return if not serie
        points = serie.data
        point = getPoint signal, data
        # 如果此point的时间是之前的记录 则不处理
        if $scope.subCount ==1 and (point.value[0] < points[7].value[0])
          return
        points.push point
        if points.length > maxPoints
          points.shift()
        point

      querySignalRecords = (signals, page=1, pageItems=6, sorting={'timestamp': 1}, mode, period, callback) =>
        return if not signals or (not signals.length)
        filter =
#          startTime: moment($scope.formatStartTime).startOf 'day'
#          endTime: moment($scope.formatStartTime).endOf 'day'
          startTime: $scope.period.startTime       # 数据量过大，只查10分钟的历史数据
          endTime: $scope.period.endTime
        paging =
          page: page
          pageItems: pageItems
        @commonService.querySignalsHistoryData signals, filter.startTime, filter.endTime, (err, records, pageInfo)=>
          callback? err, records
        , paging, sorting


      queryStatisticRecords = (signals, mode='day', period, callback) =>
        return if not signals or (not signals.length)
        if mode is 'now'
          _querySignalRecords = Rx.Observable.fromCallback querySignalRecords
          observableBatch = _.map signals, (s) -> (_querySignalRecords [s], 1, 8, {timestamp: -1}, null, period)
          $scope.rxSubscribe?.dispose()
          $scope.rxSubscribe = Rx.Observable.forkJoin(observableBatch).subscribe(
            (resArr) ->
              result = {}
              _.each resArr, (item) -> _.extend result, item[1]
              for signal in signals
                $scope.subscribeSignal signal
              return callback? null, result
          )

      getLegend = (signals) ->
        legend = []
        for s in signals
          legend.push s.model.name
        legend

      getPoints = (signal, values) ->
        points = []
        for value in values
          point = getPoint signal, value
          points.push point
#        _.sortBy points, (p) -> p.value[0]
        points = _.sortBy points,'name'
        points

      getPoint = (signal, value) ->
        timestamp = moment(value.timestamp).format 'HH:mm:ss'
        tooltip = "#{signal.model.name}: #{formatString(value.value, 'float', '0.[00]')}<br/>#{moment(value.timestamp).format('YYYY-MM-DD HH:mm:ss')}"
        point =
          name: timestamp
          value: [
            new Date value.timestamp
            value.value
            tooltip
          ]
        point

      getSeries = (signals, values) ->
        return if not signals.length
        series = []
        for k, v of values
          signal = _.find signals, (s) -> s.key is k
          points = getPoints signal, v.values
          sere =
            name: signal?.model.name
            type: 'line'
            smooth: true
            data: points
          series.push sere
        series

      createOption = (title, signals, values) =>
        series = getSeries signals, values
        legend = getLegend signals
        option =
          title:
            text: $scope.parameters.title || '实时数据曲线'
            padding: [15,10]
            textStyle:
              color: '#EBEEF7'
              fontSize: 28
            top: 28
            left: 30
          grid:
            left: 40,
            top: 120,
            bottom: 60,
            right: 80,
            containLabel: true
          tooltip:
            trigger: 'axis'
            formatter: (params) ->
              params[0]?.data?.value?[2] ? ''
          color: $scope.parameters.colors
          legend:
            top: 36
            itemWidth: 45
            itemHeight: 20
            textStyle:
              color: '#F4F7FF'
              fontSize: 18
            data: legend
          dataZoom: [
            {
              type: 'slider'
              textStyle:
                color: '#EBEEF7'
              height: 18
              start: 0
              end: 100
              bottom: 30
            }
            {
              type: 'inside'
              start: 0
              end: 100
            }
          ]
          xAxis:
            type: 'time'
            axisLine:
              show: false
              lineStyle:
                color: '#b5c2d6'
            axisTick:
              show: false
            splitLine:         #分隔线
              show: true,     #默认显示，属性show控制显示与否
              lineStyle:    #属性lineStyle（详见lineStyle）控制线条样式
#                color: ['#abbeda'],
                color: ['rgba(0,167,255,0.1)'],
                width: 1,
#                type: 'dashed'
          yAxis:
            name: $scope.parameters.yname || ""
            max: $scope.parameters.ymax
            min: $scope.parameters.ymin
            type: 'value'
            axisLine:
              show: false
              lineStyle:
                color: '#b5c2d6'
            axisTick:
              show: false
            splitLine:         #分隔线
              show: true,     #默认显示，属性show控制显示与否
              lineStyle:    #属性lineStyle（详见lineStyle）控制线条样式
#                color: ['#abbeda'],
                color: ['rgba(0,167,255,0.1)'],
                width: 1,
#                type: 'dashed'
            axisLabel:
#              formatter: "{value}"
              formatter: (value, index)->
                return value.toFixed(1)
          series: series
        option

      $scope.resize=()=>
        @$timeout =>
          $scope.myChart?.resize()
        ,100
      window.addEventListener 'resize', $scope.resize
      window.dispatchEvent(new Event('resize'))
      @$timeout ()=>
        window.dispatchEvent(new Event('resize'))
      ,1000

    resize: ($scope)->
      $scope.myChart?.resize()

    dispose: ($scope)->
      $scope.myChart?.dispose()
      $scope.myChart = null
      $scope.rxSubscribe?.dispose()
      _.mapObject $scope.opcSignalSubscription, (val) =>
        val?.dispose()


  exports =
    OpcCurveDirective: OpcCurveDirective