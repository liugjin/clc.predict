###
* File: stream-compare-directive
* User: David
* Date: 2020/04/01
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class StreamCompareDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-compare"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.previousStreamList = []
      scope.currentItem = null
      scope.selectSignals = []
#     当前流数据配置存储的变量，chartOpts1为显示配置，chartDatas1为当前所有数据和配置，用两个变量是为了播放暂停功能
      scope.chartOpts1 = {}
      scope.chartDatas1 = {}
#     对比流数据配置存储的变量
      scope.chartOpts2 = {}
      scope.chartDatas2 = {}
      scope.equipSubscription = {}
      scope.chartOpts1.legends = []
      scope.chartOpts1.yDatas = []
      scope.chartOpts2.legends = []
      scope.chartOpts2.yDatas = []
#      播放暂停控制位
      scope.playFlag = false
#     控制显示的数据类型，1为仅显示当前文件数据，2为显示当前与对比两组文件数据
      scope.compareFlag = 1
#      控制流数据种类,1为原始数据，2为算法处理后的数据
      scope.streamType = 1
      #      此变量用于控制文件里读到的数据是1组还是3组
      scope.dataNumFlag = 1
      scope.urls = []
#     播放暂停定时器
      scope.interval1 = null
      scope.query =
        startTime:''
        endTime:''
      scope.selectSignal = (sig)->
        scope.selectSignals = [sig]
        scope.echart1?.dispose()
        scope.echart2?.dispose()
        scope.mychart?.dispose()
        scope.compareFlag = 1
        $('#mysigs').hide()
        clearInterval(scope.interval1)
        queryStreamSignalRecords()
        scope.queryStreamData()


      scope.dataFlag = false
#      scope.timeSubscription = null
      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')
        console.log '时间-----'
        queryStreamSignalRecords()

      scope.selectEquipSubscription?.dispose()
      scope.selectEquipSubscription = @commonService.subscribeEventBus 'selectEquip',(msg)=>
        scope.multiflag = false
        scope.selectedEquips = [msg.message]
        scope.compareFlag = 1
        clearInterval(scope.interval1)
        scope.selectedEquips = _.filter scope.selectedEquips,(item)=>
          item.level == 'equipment'
        loadEquipmentAndSignals scope.selectedEquips,(data)=>
#            如果是单个设备 data(scope.signals)就是此设备的所有信号
          scope.selectSignals = [scope.signals[0]]
          #          选中设备后自动查询当天的数据
          if scope.selectSignals.length
            scope.dataFlag = false
            scope.echart1?.dispose()
            scope.echart2?.dispose()
            scope.mychart?.dispose()
            console.log '选择设备'
            queryStreamSignalRecords()
            scope.queryStreamData()

#     查询所选时间段内流数据往期的记录
      queryStreamSignalRecords = ()=>
        return if checkFilter()
        filter ={}
        filter["$or"] = _.map scope.selectedEquips,(equip) -> return {station:equip.station,equipment:equip.id}
        filter.startTime = scope.query.startTime
        filter.endTime = scope.query.endTime
        filter.user = scope.selectSignals[0].model.user
        filter.project = scope.selectSignals[0].model.project
        filter.signal = scope.selectSignals[0].model.signal
        filter.mode= {"$nin":["event"]}
        data =
          filter: filter
          paging: null
          sorting: {station:1,equipment:1,timestamp:1}
        @commonService.reportingService.querySignalRecords data,(err,records) =>
          return console.log('err:',err) if err
          console.log records
          for record in records
            str = '第'+moment(record.timestamp).format("YYYY-MM-DD HH:mm:ss")+'期'
            record.timeName = str
          scope.previousStreamList = records
          scope.currentPreviousStream = records[0]
#            流数据往期与当期对比功能函数
      scope.streamDataComparing = ()=>
        url = scope.currentPreviousStream.value
        scope.collectTime2 = moment(scope.currentPreviousStream.timestamp).format("YYYY-MM-DD HH:mm:ss")
        if scope.currentPreviousStream
          scope.compareFlag = 2
          if scope.streamType == 1
            originStreamData2(url,2)
          else if scope.streamType == 2
            xhr = new XMLHttpRequest()
            xhr.open('get', url,true)
            xhr.responseType ='arraybuffer'
            xhr.onload = (e)=>
              scope.$root.loading = true
              if xhr.status ==200
                data =new Uint8Array(xhr.response)
                wb = XLSX.read(data, {type:'array'})
                testStr = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]])
                jsonToStringData(testStr,2)
            xhr.send()
        else
          @display "请选择流数据往期号"
#          获取所选设备所有的流数据信号
      loadEquipmentAndSignals= (equipments,callback)=>
        scope.equipments=[]
        scope.signals = []
        #        index = 0
        #        这里equipments 的length只能为1
        for equip in equipments
          if equip.level is 'equipment'
            stationId = equip.station
            equipmentId=equip.id
            for station in scope.project.stations.items
              if(station?.model.station is stationId)
                @commonService.loadEquipmentById station,equipmentId,(err,equipment)=>
                  return console.log("err:",err) if err
                  scope.equipments.push(equipment)
                  equipment.loadSignals null, (err, model) =>
                    return console.log("err:",err) if err
                    finalData = _.uniq model
                    streamSignals = _.filter finalData,(sig)=>
                      sig.model.visible is true and sig.model.dataType in ['json','string'] and sig.model.group in ['stream','ttf']
                    #                   流式数据信号里面要去掉manual-describe和s-data-result这两个信号
                    scope.signals = _.filter streamSignals,(sig)=>
                      sig.model.signal not in ['manual-describe','s-data-result']

                    callback? true
      scope.selectCurrentStream = (item)=>
        scope.currentPreviousStream = item
      checkFilter =()->
        if not scope.selectedEquips or (not scope.selectedEquips.length)
          M.toast({html:'请选择设备'})
          return true
        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      # 过滤信号
      scope.filterSig = ()=>
        (equipment) =>
          if equipment.model.dataType in ["int","float","enum","string"]
            return true
          return false
#选择系列数据
      scope.selectSeriesData = (abc,index)=>
        clearInterval(scope.interval1)
        legendIndex = Number(scope.chartOpts1.currentLegends.index)
        abcIndex = Number(index + 1)
        scope.currentDisplayList = scope.streamLegendList[index]
        scope.chartOpts1.currentAbcSeries = scope.chartOpts2.currentAbcSeries = scope.abcSeriesList[index]
        scope.chartOpts1.currentLegends = scope.chartOpts2.currentLegends = scope.currentDisplayList[legendIndex]

        scope.chartOpts1.yData1 = scope.chartDatas1['data'+abcIndex].yData1[legendIndex]
        scope.chartOpts1.yData2 = scope.chartDatas1['data'+abcIndex].yData2[legendIndex]
        scope.currentMinAndMax[0] = scope.maxAndMins['minAndMax'+abcIndex].yData1MinAndMax[legendIndex]
        scope.currentMinAndMax[1] = scope.maxAndMins['minAndMax'+abcIndex].yData2MinAndMax[legendIndex]
        if scope.compareFlag == 2
          scope.chartOpts2.yData1 = scope.chartDatas2['data'+abcIndex].yData1[legendIndex]
          scope.chartOpts2.yData2 = scope.chartDatas2['data'+abcIndex].yData2[legendIndex]
          scope.compareMinAndMax[0] = scope.maxAndMins2['minAndMax'+abcIndex].yData1MinAndMax[legendIndex]
          scope.compareMinAndMax[1] = scope.maxAndMins2['minAndMax'+abcIndex].yData2MinAndMax[legendIndex]

        if scope.chartOpts2.yData1 && scope.compareFlag == 2
          appendStreamData()
        else
          reSetChartOpts(scope.chartOpts1)
      scope.selectLegend = (leg, index)=>
        clearInterval(scope.interval1)
        scope.chartOpts1.currentLegends = scope.chartOpts2.currentLegends = scope.currentDisplayList[index]
        if scope.chartOpts1.currentAbcSeries
          abcIndex = Number(scope.chartOpts1.currentAbcSeries.index + 1)
          scope.chartOpts1.yData1 = scope.chartDatas1['data'+abcIndex].yData1[index]
          scope.chartOpts1.yData2 = scope.chartDatas1['data'+abcIndex].yData2[index]
          scope.currentMinAndMax[0] = scope.maxAndMins['minAndMax'+abcIndex].yData1MinAndMax[index]
          scope.currentMinAndMax[1] = scope.maxAndMins['minAndMax'+abcIndex].yData2MinAndMax[index]
          if scope.compareFlag == 2
            scope.chartOpts2.yData1 = scope.chartDatas2['data'+abcIndex].yData1[index]
            scope.chartOpts2.yData2 = scope.chartDatas2['data'+abcIndex].yData2[index]
            scope.compareMinAndMax[0] = scope.maxAndMins2['minAndMax'+abcIndex].yData1MinAndMax[index]
            scope.compareMinAndMax[1] = scope.maxAndMins2['minAndMax'+abcIndex].yData2MinAndMax[index]
        else
          scope.chartOpts1.yData1 = scope.chartDatas1.yData1[index]
          scope.chartOpts1.yData2 = scope.chartDatas1.yData2[index]
          scope.currentMinAndMax[0] = scope.maxAndMins.yData1MinAndMax[index]
          scope.currentMinAndMax[1] = scope.maxAndMins.yData2MinAndMax[index]
          if scope.compareFlag == 2
            scope.chartOpts2.yData1 = scope.chartDatas2.yData1[index]
            scope.chartOpts2.yData2 = scope.chartDatas2.yData2[index]
            scope.compareMinAndMax[0] = scope.maxAndMins.yData1MinAndMax[index]
            scope.compareMinAndMax[1] = scope.maxAndMins.yData2MinAndMax[index]

        if scope.chartOpts2.yData1 && scope.compareFlag == 2
          appendStreamData()
        else
          reSetChartOpts(scope.chartOpts1)
#根据信号是否带ttf后缀区分是原始数据文件还是处理后的流数据文件
      scope.queryStreamData = (page=1,pageItems=10)=>
        return if checkFilter()
        if scope.selectSignals[0]
          signal = scope.selectSignals[0].model.signal
          str = signal.split('-')
          scope.streamLegendList = []
          
          if str.length == 4 && str[3] == 'ttf'
            scope.streamType = 2
            scope.currentMinAndMax = [[0,0],[0,0]]
            scope.compareMinAndMax = [[0,0],[0,0]]
            scope.chartOpts1.normalDatas = [[-20000000,20000000],[0,200]]
            scope.chartOpts1.end = 10
            scope.chartOpts1.start = 0
            scope.abcSeriesList = []
            scope.chartOpts1.legends = []
            scope.maxAndMins = {}
            scope.maxAndMins2 = {}
            scope.streamLegendList = []
            scope.currentDisplayList = []
            scope.chartOpts1.title1 = scope.selectSignals[0].model.name + '时域图'
            scope.chartOpts1.title2 = scope.selectSignals[0].model.name + '频域图'
            getStreamSignalData(1)
          else
            scope.streamType = 1

            if signal == 's-data-7' || signal == 's-data-7-ttf'
              scope.legendList = ['A相电流','B相电流','C相电流']
            else if signal == 's-data-5' || signal == 's-data-6'
              scope.legendList = ['X轴震动','Y轴震动','Z轴震动']
            else
              scope.legendList = [scope.selectSignals[0].model.name]
            scope.chartOpts1.legends = scope.legendList
            scope.chartOpts1.end = 2
            scope.chartOpts1.start = 0
            scope.currentMinAndMax = [0,0]
            scope.compareMinAndMax = [0,0]
            getStreamDataOrigin(1)


#            获取并解析处理后的流数据文件
      getStreamSignalData = (dindex)=>
        filter =
          user: scope.project.model.user
          project: scope.project.model.project
          station: scope.selectedEquips[0].station
          equipment: scope.selectedEquips[0].id
          signal: scope.selectSignals[0].model.signal
        strId = scope.selectedEquips[0].station+"-"+scope.selectedEquips[0].id + "-"+ scope.selectSignals[0].model.signal
        scope.equipSubscription[strId]?.dispose()
        scope.equipSubscription[strId] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
          if signal.message && signal.message.value
            scope.collectTime = moment(signal.message.timestamp).format("YYYY-MM-DD HH:mm:ss")
            scope.dataFlag = true
            scope.$root.loading = true
            scope.dataUrl = signal.message.value
            xhr = new XMLHttpRequest()
            xhr.open('get', scope.dataUrl,true)
            xhr.responseType ='arraybuffer'
            xhr.onload = (e)=>
              scope.$root.loading = true
              if xhr.status ==200
                data =new Uint8Array(xhr.response)
                wb = XLSX.read(data, {type:'array'})
                testStr = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]])
                jsonToStringData(testStr,dindex)
            xhr.send()
#      解析从处理后的流数据文件中读到的数据,根据dataNumFlag的值区分是1组还是3组数据
      jsonToStringData = (data,dindex)=>
        if Array.isArray(data)
          scope.streamLegendList = []
          scope['chartOpts'+dindex].legends = []
          keyData = data[0]
          for j,k of keyData
            scope['chartOpts'+dindex].legends.push(j)
          if scope['chartOpts'+dindex].legends.length == 21
            scope['chartOpts'+dindex].legends.pop()
            scope['chartDatas'+dindex].data1 =
              yData1: [[],[],[]]
              yData2: [[],[],[]]
            scope['chartDatas'+dindex].data2 =
              yData1: [[],[],[]]
              yData2: [[],[],[]]
            scope['chartDatas'+dindex].data3 =
              yData1: [[],[],[]]
              yData2: [[],[],[]]
            scope['chartOpts'+dindex].legends.splice(6,1)
            scope['chartOpts'+dindex].legends.splice(12,1)
            scope.dataNumFlag = 3
            for j in [0,1,2]
              scope.streamLegendList.push([])
              for i in[0,1,2]
                name1 = scope['chartOpts'+dindex].legends[i+j*6]
                name2 = scope['chartOpts'+dindex].legends[i+j*6+3]
                name = name1 + ',' + name2
                scope.streamLegendList[j].push({legend1:name1, legend2:name2,name:name,index:i,optindex:j})
            dataAnalysis3(data,dindex)
          else if scope['chartOpts'+dindex].legends.length == 7
            scope['chartOpts'+dindex].legends.pop()
            scope['chartDatas'+dindex].yData1 = [[],[],[]]
            scope['chartDatas'+dindex].yData2 = [[],[],[]]
            scope.dataNumFlag = 1
            for i in [0,1,2]
              name1 = scope['chartOpts'+dindex].legends[i]
              name2 = scope['chartOpts'+dindex].legends[i+3]
              name = name1 + ',' + name2
              scope.streamLegendList.push({legend1:name1, legend2:name2,name:name,index:i})
            dataAnalysis1(data,dindex)
#单组数据的解析，并根据dindex判断是画当前流数据线图还是对比线图
      dataAnalysis1 = (data,dindex)=>
        xData= []
        yData1MinAndMax = [[],[],[]]
        yData2MinAndMax = [[],[],[]]
        scope['chartOpts'+dindex].normalDatas = [[-20000000,20000000],[0,50]]
        for item,i in data
          xData.push(i+1)
          scope['chartDatas'+dindex].yData1[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[0]]))
          scope['chartDatas'+dindex].yData1[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[1]]))
          scope['chartDatas'+dindex].yData1[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[2]]))
          scope['chartDatas'+dindex].yData2[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[3]]))
          scope['chartDatas'+dindex].yData2[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[4]]))
          scope['chartDatas'+dindex].yData2[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[5]]))

        scope['chartOpts'+dindex].xData = xData
        if scope['chartOpts'+dindex].currentLegends
          scope['chartOpts'+dindex].currentLegends = scope.streamLegendList[scope.chartOpts1.currentLegends.index]
        else
          scope['chartOpts'+dindex].currentLegends = scope.streamLegendList[0]
        scope['chartOpts'+dindex].yData1 = scope['chartDatas'+dindex].yData1[scope.chartOpts1.currentLegends.index]
        scope['chartOpts'+dindex].yData2 = scope['chartDatas'+dindex].yData2[scope.chartOpts1.currentLegends.index]
        
        scope.currentDisplayList = scope.streamLegendList
        scope['chartDatas'+dindex].xData = xData
        scope.$root.loading = false
        if dindex == 1
          scope.InitChartOpt(dindex)
        else if dindex == 2
          appendStreamData(1)
        yData1MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].yData1[0]),Math.max.apply(Math,scope['chartDatas'+dindex].yData1[0]))
        yData1MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].yData1[1]),Math.max.apply(Math,scope['chartDatas'+dindex].yData1[1]))
        yData1MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].yData1[2]),Math.max.apply(Math,scope['chartDatas'+dindex].yData1[2]))
        yData2MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].yData2[0]),Math.max.apply(Math,scope['chartDatas'+dindex].yData2[0]))
        yData2MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].yData2[1]),Math.max.apply(Math,scope['chartDatas'+dindex].yData2[1]))
        yData2MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].yData2[2]),Math.max.apply(Math,scope['chartDatas'+dindex].yData2[2]))
        if dindex == 1
          scope.maxAndMins.yData1MinAndMax = yData1MinAndMax
          scope.maxAndMins.yData2MinAndMax = yData2MinAndMax
          scope.currentMinAndMax[0] = yData1MinAndMax[scope.chartOpts1.currentLegends.index]
          scope.currentMinAndMax[1] = yData2MinAndMax[scope.chartOpts1.currentLegends.index]
        else if dindex == 2
          scope.maxAndMins.compareyData1MinAndMax = yData1MinAndMax
          scope.maxAndMins.compareyData2MinAndMax = yData2MinAndMax
          scope.compareMinAndMax[0] = yData1MinAndMax[scope.chartOpts1.currentLegends.index]
          scope.compareMinAndMax[1] = yData2MinAndMax[scope.chartOpts1.currentLegends.index]
        scope.$applyAsync()

#   3组数据的解析，并根据dindex判断是画当前流数据线图还是对比线图
      dataAnalysis3 = (data,dindex)=>
        xData = []
        signal = scope.selectSignals[0].model.signal
        if signal == 's-data-7-ttf'
          seriesSelect = ['A相电流','B相电流','C相电流']
        else if signal == 's-data-5-ttf' || signal == 's-data-6-ttf'
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
        if scope.chartOpts1.currentAbcSeries
          scope['chartOpts'+dindex].currentAbcSeries = scope.abcSeriesList[scope.chartOpts1.currentAbcSeries.index]
          scope.currentDisplayList = scope.streamLegendList[scope.chartOpts1.currentAbcSeries.index]
        else
          scope['chartOpts'+dindex].currentAbcSeries = scope.abcSeriesList[0]
          scope.currentDisplayList = scope.streamLegendList[0]

        if scope.chartOpts1.currentLegends
          scope['chartOpts'+dindex].currentLegends = scope.currentDisplayList[scope.chartOpts1.currentLegends.index]
        else
          scope['chartOpts'+dindex].currentLegends = scope.currentDisplayList[0]
        for item,i in data
          xData.push(i+1)
          scope['chartDatas'+dindex].data1.yData1[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[0]]))
          scope['chartDatas'+dindex].data1.yData1[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[1]]))
          scope['chartDatas'+dindex].data1.yData1[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[2]]))
          scope['chartDatas'+dindex].data1.yData2[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[3]]))
          scope['chartDatas'+dindex].data1.yData2[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[4]]))
          scope['chartDatas'+dindex].data1.yData2[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[5]]))
          scope['chartDatas'+dindex].data2.yData1[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[6]]))
          scope['chartDatas'+dindex].data2.yData1[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[7]]))
          scope['chartDatas'+dindex].data2.yData1[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[8]]))
          scope['chartDatas'+dindex].data2.yData2[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[9]]))
          scope['chartDatas'+dindex].data2.yData2[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[10]]))
          scope['chartDatas'+dindex].data2.yData2[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[11]]))
          scope['chartDatas'+dindex].data3.yData1[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[12]]))
          scope['chartDatas'+dindex].data3.yData1[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[13]]))
          scope['chartDatas'+dindex].data3.yData1[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[14]]))
          scope['chartDatas'+dindex].data3.yData2[0].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[15]]))
          scope['chartDatas'+dindex].data3.yData2[1].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[16]]))
          scope['chartDatas'+dindex].data3.yData2[2].push(scope.checkIfNumber(item[scope['chartOpts'+dindex].legends[17]]))

        scope['chartOpts'+dindex].xData = xData
        if scope.compareFlag == 1
          scope['chartOpts'+dindex].yData1 = scope['chartDatas'+dindex].data1.yData1[0]
          scope['chartOpts'+dindex].yData2 = scope['chartDatas'+dindex].data1.yData2[0]
        else if scope.compareFlag == 2
          num1 = scope.chartOpts1.currentAbcSeries.index + 1
          num2 = scope.chartOpts1.currentLegends.index
          scope['chartOpts'+dindex].yData1 = scope['chartDatas'+dindex]['data'+num1].yData1[num2]
          scope['chartOpts'+dindex].yData2 = scope['chartDatas'+dindex]['data'+num1].yData2[num2]
        scope['chartDatas'+dindex].xData = xData
        scope.$root.loading = false
        if dindex == 1 
          scope.InitChartOpt(dindex)
        else if dindex == 2
          appendStreamData(dindex)
        minAndMax1.yData1MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].data1.yData1[0]),Math.max.apply(Math,scope['chartDatas'+dindex].data1.yData1[0]))
        minAndMax1.yData1MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].data1.yData1[1]),Math.max.apply(Math,scope['chartDatas'+dindex].data1.yData1[1]))
        minAndMax1.yData1MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].data1.yData1[2]),Math.max.apply(Math,scope['chartDatas'+dindex].data1.yData1[2]))
        minAndMax1.yData2MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].data1.yData2[0]),Math.max.apply(Math,scope['chartDatas'+dindex].data1.yData2[0]))
        minAndMax1.yData2MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].data1.yData2[1]),Math.max.apply(Math,scope['chartDatas'+dindex].data1.yData2[1]))
        minAndMax1.yData2MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].data1.yData2[2]),Math.max.apply(Math,scope['chartDatas'+dindex].data1.yData2[2]))
        minAndMax2.yData1MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].data2.yData1[0]),Math.max.apply(Math,scope['chartDatas'+dindex].data2.yData1[0]))
        minAndMax2.yData1MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].data2.yData1[1]),Math.max.apply(Math,scope['chartDatas'+dindex].data2.yData1[1]))
        minAndMax2.yData1MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].data2.yData1[2]),Math.max.apply(Math,scope['chartDatas'+dindex].data2.yData1[2]))
        minAndMax2.yData2MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].data2.yData2[0]),Math.max.apply(Math,scope['chartDatas'+dindex].data2.yData2[0]))
        minAndMax2.yData2MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].data2.yData2[1]),Math.max.apply(Math,scope['chartDatas'+dindex].data2.yData2[1]))
        minAndMax2.yData2MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].data2.yData2[2]),Math.max.apply(Math,scope['chartDatas'+dindex].data2.yData2[2]))
        minAndMax3.yData1MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].data3.yData1[0]),Math.max.apply(Math,scope['chartDatas'+dindex].data3.yData1[0]))
        minAndMax3.yData1MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].data3.yData1[1]),Math.max.apply(Math,scope['chartDatas'+dindex].data3.yData1[1]))
        minAndMax3.yData1MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].data3.yData1[2]),Math.max.apply(Math,scope['chartDatas'+dindex].data3.yData1[2]))
        minAndMax3.yData2MinAndMax[0].push(Math.min.apply(Math,scope['chartDatas'+dindex].data3.yData2[0]),Math.max.apply(Math,scope['chartDatas'+dindex].data3.yData2[0]))
        minAndMax3.yData2MinAndMax[1].push(Math.min.apply(Math,scope['chartDatas'+dindex].data3.yData2[1]),Math.max.apply(Math,scope['chartDatas'+dindex].data3.yData2[1]))
        minAndMax3.yData2MinAndMax[2].push(Math.min.apply(Math,scope['chartDatas'+dindex].data3.yData2[2]),Math.max.apply(Math,scope['chartDatas'+dindex].data3.yData2[2]))

        if scope.compareFlag == 1
          scope.maxAndMins.minAndMax1 = minAndMax1
          scope.maxAndMins.minAndMax2 = minAndMax2
          scope.maxAndMins.minAndMax3 = minAndMax3
          scope.currentMinAndMax[0] = minAndMax1.yData1MinAndMax[0]
          scope.currentMinAndMax[1] = minAndMax1.yData2MinAndMax[0]
        else if scope.compareFlag == 2
          scope.maxAndMins2.minAndMax1 = minAndMax1
          scope.maxAndMins2.minAndMax2 = minAndMax2
          scope.maxAndMins2.minAndMax3 = minAndMax3
          scope.compareMinAndMax[0] = minAndMax1.yData1MinAndMax[0]
          scope.compareMinAndMax[1] = minAndMax1.yData2MinAndMax[0]
        scope.$applyAsync()

#        重设原始流数据的chart设置
      reSetOringinChartOpts = (opts)=>
        series1 = []
        for item, index in opts.yData
          series1.push({
            data:item
          })
        scope.mychart.setOption {
          series:series1
        }
#        重设处理后的流数据的chart设置
      reSetChartOpts = (opts)=>
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
#        添加处理后的对比流数据，并重画echart线图
      appendStreamData = (index)=>
        series1 = []
        series2 = []
        colors = ['#1A45A2','#00E7EE','#90D78A','#1CAA9E','#F9722C','#FF085C']
        legend1 = '当前'+scope.chartOpts1.currentLegends.legend1
        legend2 = '对比'+scope.chartOpts2.currentLegends.legend1
        legend3 = '当前'+scope.chartOpts1.currentLegends.legend2
        legend4 = '对比'+scope.chartOpts2.currentLegends.legend2
        visualMap1 = []
        visualMap2 = []
        gtx= [[-20000000,20000000],[0,50]]
        visualMap1.push({
          seriesIndex:0,
          pieces: [{
            gt: gtx[0][0],
            lte: gtx[0][1],
            color: colors[0]
          }]
        },{
          seriesIndex:1,
          show: false
          pieces: [{
            gt: gtx[0][0],
            lte: gtx[0][1],
            color: colors[1]
          }]
          outOfRange:
            color: 'red'
        })
        visualMap2.push({
          seriesIndex:0,
          pieces: [{
            gt: gtx[1][0],
            lte: gtx[1][1],
            color: colors[2]
          }]
          outOfRange:
            color: 'red'
        },{
          seriesIndex:1,
          show: false
          pieces: [{
            gt: gtx[1][0],
            lte: gtx[1][1],
            color: colors[3]
          }]
          outOfRange:
            color: 'red'
        })
        series1.push({
          name: legend1
          type: 'line'
          data:scope.chartOpts1.yData1
        },{
          name: legend2
          type: 'line'
          data:scope.chartOpts2.yData1
        })
        series2.push(
          {
            name: legend3
            type: 'line'
            data:scope.chartOpts1.yData2
          },{
            name: legend4
            type: 'line'
            data:scope.chartOpts2.yData2
          }
        )
        scope.$root.loading = false
        scope.echart1.setOption {
          visualMap:visualMap1
          legend:
            data: [legend1,legend2]
          series:series1
        }
        scope.echart2.setOption {
          visualMap:visualMap2
          legend:
            data: [legend3,legend4]
          series:series2
        }
#     全部展示功能
      scope.chartShowAll = ()=>
        clearInterval(scope.interval1)
        scope.playFlag = false
        if scope.streamType == 1 && scope.compareFlag == 1
          if scope.mychart && scope.chartOpts1 && scope.chartDatas1.xData
            if scope.chartOpts1.legends.length == 1
              scope.chartOpts1.yData[0] = scope.chartDatas1.yData[0]
            else
              scope.chartOpts1.yData[0] = scope.chartDatas1.yData[0]
              scope.chartOpts1.yData[1] = scope.chartDatas1.yData[1]
              scope.chartOpts1.yData[2] = scope.chartDatas1.yData[2]
            reSetOringinChartOpts(scope.chartOpts1)
        else if scope.streamType == 1 && scope.compareFlag == 2
          if scope.mychart && scope.chartOpts1 && scope.chartDatas1.xData
            if scope.chartOpts1.legends.length == 1
              scope.chartOpts1.yData[0] = scope.chartDatas1.yData[0]
              scope.chartOpts2.yData[0] = scope.chartDatas2.yData[0]
            else
              scope.chartOpts1.yData[0] = scope.chartDatas1.yData[0]
              scope.chartOpts1.yData[1] = scope.chartDatas1.yData[1]
              scope.chartOpts1.yData[2] = scope.chartDatas1.yData[2]
              scope.chartOpts2.yData[0] = scope.chartDatas2.yData[0]
              scope.chartOpts2.yData[1] = scope.chartDatas2.yData[1]
              scope.chartOpts2.yData[2] = scope.chartDatas2.yData[2]
            appendOriginStreamData()
        else if scope.streamType == 2 && scope.compareFlag == 1
          if scope.echart1 && scope.chartOpts1 && scope.chartDatas1.xData
            if scope.dataNumFlag == 1
              legendIndex = Number(scope.chartOpts1.currentLegends.index)
              scope.chartOpts1.yData1 = scope.chartDatas1.yData1[legendIndex]
              scope.chartOpts1.yData2 = scope.chartDatas1.yData2[legendIndex]
            else
              abcIndex = Number(scope.chartOpts1.currentAbcSeries.index + 1)
              legendIndex = Number(scope.chartOpts1.currentLegends.index)
              scope.chartOpts1.yData1 = scope.chartDatas1['data'+abcIndex].yData1[legendIndex]
              scope.chartOpts1.yData2 = scope.chartDatas1['data'+abcIndex].yData2[legendIndex]
            reSetChartOpts(scope.chartOpts1)
        else if scope.streamType == 2 && scope.compareFlag == 2
          if scope.echart1 && scope.chartOpts1 && scope.chartDatas1.xData
            if scope.dataNumFlag == 1
              index = scope.chartOpts1.currentLegends.index
              scope.chartOpts1.yData1 = scope.chartDatas1.yData1[index]
              scope.chartOpts1.yData2 = scope.chartDatas1.yData2[index]
              scope.chartOpts2.yData1 = scope.chartDatas2.yData1[index]
              scope.chartOpts2.yData2 = scope.chartDatas2.yData2[index]
            else
              abcIndex = Number(scope.chartOpts1.currentAbcSeries.index + 1)
              legendIndex = Number(scope.chartOpts1.currentLegends.index)
              scope.chartOpts1.yData1 = scope.chartDatas1['data'+abcIndex].yData1[legendIndex]
              scope.chartOpts1.yData2 = scope.chartDatas1['data'+abcIndex].yData2[legendIndex]
              scope.chartOpts2.yData1 = scope.chartDatas2['data'+abcIndex].yData1[legendIndex]
              scope.chartOpts2.yData2 = scope.chartDatas2['data'+abcIndex].yData2[legendIndex]
            appendStreamData()

#     播放暂停功能
      scope.chartPlayPause = ()=>
        if !scope.playFlag
#          原始数据的播放与暂停
          if scope.streamType == 1
            if scope.compareFlag == 1
              if scope.mychart && scope.chartOpts1 && scope.chartDatas1.xData
                if scope.chartOpts1.yData[0].length == scope.chartDatas1.xData.length
                  if scope.chartOpts1.legends.length == 3
                    scope.chartOpts1.yData = [[],[],[]]
                  else
                    scope.chartOpts1.yData = [[]]
                scope.playFlag = true
                #         设置echart图表播放功能
                scope.interval1 = setInterval(() =>
                  if scope.chartOpts1.yData[0].length < scope.chartDatas1.xData.length
                    i =0
                    while i<4
                      if scope.chartOpts1.legends.length == 3
                        scope.chartOpts1.yData[0].push(scope.chartDatas1.yData[0][scope.chartOpts1.yData[0].length])
                        scope.chartOpts1.yData[1].push(scope.chartDatas1.yData[1][scope.chartOpts1.yData[1].length])
                        scope.chartOpts1.yData[2].push(scope.chartDatas1.yData[2][scope.chartOpts1.yData[2].length])
                      else
                        scope.chartOpts1.yData[0].push(scope.chartDatas1.yData[0][scope.chartOpts1.yData[0].length])
                      i++
                  else
                    scope.chartOpts1.yData = [[]]
                  reSetOringinChartOpts(scope.chartOpts1)
                ,1000)
            else if scope.compareFlag == 2
              if scope.mychart && scope.chartOpts1 && scope.chartDatas1.xData
                if scope.chartOpts1.yData[0].length == scope.chartDatas1.xData.length
                  if scope.chartOpts1.legends.length == 3
                    scope.chartOpts1.yData = [[],[],[]]
                    scope.chartOpts2.yData = [[],[],[]]
                  else
                    scope.chartOpts1.yData = [[]]
                    scope.chartOpts2.yData = [[]]
                scope.playFlag = true
                #         设置echart图表播放功能
                scope.interval1 = setInterval(() =>
                  if scope.chartOpts1.yData[0].length < scope.chartDatas1.xData.length
                    i =0
                    while i<4
                      if scope.chartOpts1.legends.length == 3
                        scope.chartOpts1.yData[0].push(scope.chartDatas1.yData[0][scope.chartOpts1.yData[0].length])
                        scope.chartOpts1.yData[1].push(scope.chartDatas1.yData[1][scope.chartOpts1.yData[1].length])
                        scope.chartOpts1.yData[2].push(scope.chartDatas1.yData[2][scope.chartOpts1.yData[2].length])
                        scope.chartOpts2.yData[0].push(scope.chartDatas2.yData[0][scope.chartOpts2.yData[0].length])
                        scope.chartOpts2.yData[1].push(scope.chartDatas2.yData[1][scope.chartOpts2.yData[1].length])
                        scope.chartOpts2.yData[2].push(scope.chartDatas2.yData[2][scope.chartOpts2.yData[2].length])
                      else
                        scope.chartOpts1.yData[0].push(scope.chartDatas1.yData[0][scope.chartOpts1.yData[0].length])
                        scope.chartOpts2.yData[0].push(scope.chartDatas2.yData[0][scope.chartOpts2.yData[0].length])
                      i++
                  else
                    scope.chartOpts1.yData = [[]]
                    scope.chartOpts2.yData = [[]]
                  appendOriginStreamData()
                ,1000)
#            处理后的数据的播放与暂停
          else if scope.streamType == 2
            if scope.compareFlag == 1
              if scope.echart1 && scope.chartOpts1 && scope.chartDatas1.xData
                if scope.chartOpts1.yData1.length == scope.chartDatas1.xData.length
                  scope.chartOpts1.yData1 = []
                  scope.chartOpts1.yData2 = []
                scope.playFlag = true
                #         设置echart图表播放功能
                if scope.dataNumFlag == 1
                  legendIndex = Number(scope.chartOpts1.currentLegends.index)
                  scope.interval1 = setInterval(() =>
                    if scope.chartOpts1.yData1.length < scope.chartDatas1.xData.length
                      i =0
                      while i<2
                        scope.chartOpts1.yData1.push(scope.chartDatas1.yData1[legendIndex][scope.chartOpts1.yData1.length])
                        scope.chartOpts1.yData2.push(scope.chartDatas1.yData2[legendIndex][scope.chartOpts1.yData2.length])
                        i++
                    else
                      scope.chartOpts1.yData1 = []
                      scope.chartOpts1.yData2 = []
                    reSetChartOpts(scope.chartOpts1)
                  ,1000)
                else if scope.dataNumFlag == 3
                  abcIndex = Number(scope.chartOpts1.currentAbcSeries.index + 1)
                  legendIndex = Number(scope.chartOpts1.currentLegends.index)
                  scope.interval1 = setInterval(() =>
                    if scope.chartOpts1.yData1.length < scope.chartDatas1.xData.length
                      i =0
                      while i<2
                        scope.chartOpts1.yData1.push(scope.chartDatas1['data'+abcIndex].yData1[legendIndex][scope.chartOpts1.yData1.length])
                        scope.chartOpts1.yData2.push(scope.chartDatas1['data'+abcIndex].yData2[legendIndex][scope.chartOpts1.yData2.length])
                        i++
                    else
                      scope.chartOpts1.yData1 = []
                      scope.chartOpts1.yData2 = []
                    reSetChartOpts(scope.chartOpts1)
                  ,1000)
            else if scope.compareFlag == 2
              if scope.echart1 && scope.chartOpts1 && scope.chartDatas1.xData
                if scope.chartOpts1.yData1.length == scope.chartDatas1.xData.length
                  scope.chartOpts1.yData1 = []
                  scope.chartOpts1.yData2 = []
                  scope.chartOpts2.yData1 = []
                  scope.chartOpts2.yData2 = []
                scope.playFlag = true
                #         设置echart图表播放功能
                if scope.dataNumFlag == 1
                  index = scope.chartOpts1.currentLegends.index
                  scope.interval1 = setInterval(() =>
                    if scope.chartOpts1.yData1.length < scope.chartDatas1.xData.length
                      i =0
                      while i<2
                        scope.chartOpts1.yData1.push(scope.chartDatas1.yData1[index][scope.chartOpts1.yData1.length])
                        scope.chartOpts1.yData2.push(scope.chartDatas1.yData2[index][scope.chartOpts1.yData2.length])
                        scope.chartOpts2.yData1.push(scope.chartDatas2.yData1[index][scope.chartOpts2.yData1.length])
                        scope.chartOpts2.yData2.push(scope.chartDatas2.yData2[index][scope.chartOpts2.yData2.length])
                        i++
                    else
                      scope.chartOpts1.yData1 = []
                      scope.chartOpts1.yData2 = []
                      scope.chartOpts2.yData1 = []
                      scope.chartOpts2.yData2 = []
                    appendStreamData()
                  ,1000)
                else if scope.dataNumFlag == 3
                  abcIndex = Number(scope.chartOpts1.currentAbcSeries.index + 1)
                  legendIndex = Number(scope.chartOpts1.currentLegends.index)
                  scope.interval1 = setInterval(() =>
                    if scope.chartOpts1.yData1.length < scope.chartDatas1.xData.length
                      i =0
                      while i<2
                        scope.chartOpts1.yData1.push(scope.chartDatas1['data'+abcIndex].yData1[legendIndex][scope.chartOpts1.yData1.length])
                        scope.chartOpts1.yData2.push(scope.chartDatas1['data'+abcIndex].yData2[legendIndex][scope.chartOpts1.yData2.length])
                        scope.chartOpts2.yData1.push(scope.chartDatas2['data'+abcIndex].yData1[legendIndex][scope.chartOpts2.yData1.length])
                        scope.chartOpts2.yData2.push(scope.chartDatas2['data'+abcIndex].yData2[legendIndex][scope.chartOpts2.yData2.length])
                        i++
                    else
                      scope.chartOpts1.yData1 = []
                      scope.chartOpts1.yData2 = []
                      scope.chartOpts2.yData1 = []
                      scope.chartOpts2.yData2 = []
                    appendStreamData()
                  ,1000)
        else
          clearInterval(scope.interval1)
          scope.playFlag = false
#        添加原始对比数据函数
      appendOriginStreamData = (zindex)=>
        series1 = []
        _legendData1 = _.map(scope.chartOpts1.legends, (d,i) => {name:'当前'+d,icon:"image://" + @getComponentPath('image/color'+(i+1)+'.svg')})
        _legendData2 = _.map(scope.chartOpts1.legends, (d,i) => {name:'对比'+d,icon:"image://" + @getComponentPath('image/color'+((i+_legendData1.length)%3+1)+'.svg')})
        legend = _legendData1.concat(_legendData2)
        colors = [['#1A45A2','#00E7EE'],['#90D78A','#1CAA9E'],['#F9722C','#FF085C']]

        for item, index in scope.chartOpts1.yData
          series1.push({
            type:'line'
            name:_legendData1[index].name
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
        for item, index in scope.chartOpts2.yData
          series1.push({
            type:'line'
            name:_legendData2[index].name
            data:item
            lineStyle:
              width:2
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: colors[(index+series1.length)%3][0]
                }, {
                  offset: 1, color: colors[(index+series1.length)%3][1]
                }]
              }
          })
        scope.$root.loading = false
        scope.mychart.setOption {
          legend:
            data: legend
          series:series1
        }
#            带ttf的处理后的流数据echart初始化，分时域和频域图
      scope.InitChartOpt = ()=>
#曲线图初始化
        myChart1 = element.find("#ss-chart1")
        myChart2 = element.find("#ss-chart2")
        scope.echart1?.dispose()

        scope.echart2?.dispose()
        scope.echart1 = echarts.init myChart1[0]
        scope.echart2 = echarts.init myChart2[0]
        option1 = @createOption scope.chartOpts1,0
        option2 = @createOption scope.chartOpts1,1
        scope.$root.loading = false
        scope.echart1.setOption option1
        scope.echart2.setOption option2
#        原始文件对比文件的数据处理
      originStreamData2 = (url,zindex)=>
        str = url.split(',')
        scope.compareMinAndMax = [0,0]
        if str.length == 1
          scope.chartDatas2.yData = [[]]
          scope.chartDatas2.xData = []
          $.get(str[0],null,(data)=>
            strs = data.split("\n")
            strs.pop()
            for i,j in strs
              index = j + 1
              scope.chartDatas2.xData.push(index)
              scope.chartDatas2.yData[0].push(Number(i))
            scope.chartOpts2.yData = scope.chartDatas2.yData
            scope.chartOpts2.xData = scope.chartDatas2.xData
            scope.calcCompareMinAndMax scope.chartDatas2.yData
            appendOriginStreamData()

          )
        else if str.length == 3
          scope.chartDatas2.yData = [[],[],[]]
          scope.chartDatas2.xData = []
          $.get(str[0],null,(data1)=>
            strs = data1.split("\n")
            strs.pop()
            for i,j in strs
              index = j + 1
              scope.chartDatas2.xData.push(index)
              scope.chartDatas2.yData[0].push(Number(i))
            $.get(str[1],null,(data2)=>
              strs = data2.split("\n")
              strs.pop()
              for j in strs
                scope.chartDatas2.yData[1].push(Number(j))
              $.get(str[2],null,(data3)=>
                strs = data3.split("\n")
                strs.pop()
                for k in strs
                  scope.chartDatas2.yData[2].push(Number(k))
                scope.chartOpts2.yData = scope.chartDatas2.yData
                scope.chartOpts2.xData = scope.chartDatas2.xData
                scope.calcCompareMinAndMax scope.chartDatas2.yData
                appendOriginStreamData()
                
              )
            )
          )
#            原始流数据文件订阅函数
      getStreamDataOrigin = (zindex)=>
        console.log scope
        filter =
          user: scope.project.model.user
          project: scope.project.model.project
          station: scope.selectedEquips[0].station
          equipment: scope.selectedEquips[0].id
          signal: scope.selectSignals[0].model.signal
        strId = scope.selectedEquips[0].station+"-"+scope.selectedEquips[0].id + "-"+ scope.selectSignals[0].model.signal
        scope.chartOpts1.title = scope.selectSignals[0].model.name + '原始数据图'
        scope.equipSubscription[strId]?.dispose()
        scope.equipSubscription[strId] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
          scope.chartDatas1.xData = []
          scope.urls = []
          if signal.message && signal.message.value
            scope.dataFlag = true
            scope.$root.loading = true
            chartelement = element.find('#ss-origin-chart')
            scope.mychart?.dispose()
            scope.mychart = null
            scope.mychart = echarts.init chartelement[0]
            scope.collectTime = moment(signal.message.timestamp).format("YYYY-MM-DD HH:mm:ss")
            str = signal.message.value.split(',')
            for item in str
              scope.urls.push(item)
            if scope.urls.length == 1
              scope.chartDatas1.yData = [[]]
              $.get(scope.urls[0],null,(data)=>
                strs = data.split("\n")
                strs.pop()
                for i,j in strs
                  index = j + 1
                  scope.chartDatas1.xData.push(index)
                  scope.chartDatas1.yData[0].push(Number(i))
                scope.chartOpts1.yData = scope.chartDatas1.yData
                scope.chartOpts1.xData = scope.chartDatas1.xData
                scope.calcMinAndMax scope.chartDatas1.yData
                scope.$root.loading = false
                createOriginOption scope.chartOpts1
              )
            else if scope.urls.length == 3
              scope.chartDatas1.yData = [[],[],[]]
              $.get(scope.urls[0],null,(data1)=>
                strs = data1.split("\n")
                strs.pop()
                for i,j in strs
                  index = j + 1
                  scope.chartDatas1.xData.push(index)
                  scope.chartDatas1.yData[0].push(Number(i))
                $.get(scope.urls[1],null,(data2)=>
                  strs = data2.split("\n")
                  strs.pop()
                  for j in strs
                    scope.chartDatas1.yData[1].push(Number(j))
                  $.get(scope.urls[2],null,(data3)=>
                    strs = data3.split("\n")
                    strs.pop()
                    for k in strs
                      scope.chartDatas1.yData[2].push(Number(k))
                    scope.chartOpts1.yData = scope.chartDatas1.yData
                    scope.chartOpts1.xData = scope.chartDatas1.xData
                    scope.calcMinAndMax scope.chartDatas1.yData
                    scope.$root.loading = false
                    createOriginOption scope.chartOpts1
                  )
                )
              )

      scope.checkIfNumber= (val)=>
        if !isNaN(Number(val))
          return Number(val)
        else
          return 0
#          计算当前显示的流数据的最大与最小值
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
#        计算对比的往期的流数据的最大与最小值
      scope.calcCompareMinAndMax = (data)=>
        yDataMinAndMax = []
        newData = []
        for i,j in data
          newData.push([])
          for k in i
            newData[j].push(scope.checkIfNumber(k))
        if data.length == 3
          for item,index in newData
            yDataMinAndMax.push(Math.min.apply(Math,item),Math.max.apply(Math,item))
          scope.compareMinAndMax = [Math.min.apply(Math,yDataMinAndMax),Math.max.apply(Math,yDataMinAndMax)]
        else
          yDataMinAndMax.push(Math.min.apply(Math,newData[0]),Math.max.apply(Math,newData[0]))
          scope.compareMinAndMax = yDataMinAndMax
        scope.$applyAsync()

# 画原始流数据echart线图
      createOriginOption = (opts)=>
        colors = [['#1A45A2','#00E7EE'],['#90D78A','#1CAA9E'],['#F9722C','#FF085C']]
        series = []
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
          tooltip:
            show: true
            trigger: "axis"
            axisPointer: {
              type: 'cross'
            }
          legend:
            show: true
            bottom: '4%'
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
#                type: ['line', 'bar']
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
        scope.$root.loading = false
        scope.mychart.setOption(option)
# 画处理后的流数据的时域与频域图
    createOption: (opts,index) =>
      i = Number(index + 1)
      color = ['#00E7EE','#4169E1','#90D78A','#1CAA9E']

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
        tooltip:
          show: true
          trigger: "axis"
          axisPointer: {
            type: 'cross'
          }
        legend:
          show: true
          orient: "horizontal"
          right: 0
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
        scope.mychart?.resize()
      ,0

    dispose: (scope)->
      for key, value of scope.equipSubscription
        value?.dispose()
      scope.echart1?.dispose()
      scope.echart1 = null
      scope.echart2?.dispose()
      scope.echart2 = null
      scope.mychart?.dispose()
      scope.mychart = null
      scope.timeSubscription?.dispose()
      scope.selectEquipSubscription?.dispose()
      clearInterval(scope.interval1)


  exports =
    StreamCompareDirective: StreamCompareDirective