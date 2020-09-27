###
* File: report-historysignal-directive
* User: David
* Date: 2019/01/03
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportStreamSignalDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-stream-signal"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      查询流数据记录，包括采集上来的流数据及算法分析后的流数据。 string或json类型数据
      scope.multiflag = null
      scope.view = false
      scope.viewName = "报表11"
      scope.reportName = "高频数据记录表"
      scope.currentItem = null
      scope.selectSignals = []
      scope.clickFlag = false
      scope.query =
        startTime:''
        endTime:''
      scope.headers = [
        {headerName:"序号", field: "index",width: 50},
        {headerName:"项目名称", field: "stationName"},
        {headerName:"设备名称", field: "equipmentName"},
        {headerName:"数据名称",     field: "signalName"},
        {headerName:"数据值", field: "value",minWidth:910},
        {headerName:"采集时间", field: "sampleTime"}
      ]
      scope.garddatas = [
        {index:"",stationName:"暂无数据",equipmentName:"暂无数据",signalName:"",value:"",sampleTime:""}
      ]
#      manualHeaders = [
#        {headerName:"序号",field: "index",width:50},
#        {headerName:"项目名称",field:"stationName"},
#        {headerName:"设备名称",field:"equipmentName"},
#        {headerName:"数据名称", field:"signalName"},
#        {headerName:"故障预测",field:"vSignalName"},
#        {headerName:"预测值",field:"value",width:100},
#        {headerName:"备注",field:"text"},
#        {headerName:"操作人",field:"user"},
#        {headerName:"采集时间",field:"sampleTime"}
#      ]
#      manualGarddatas = [
#        {index:"",stationName:"暂无数据",equipmentName:"暂无数据",signalName:"",vSignalName:"",value:"",text:"",user:"",sampleTime:""}
#      ]
#      scope.garddatas = manualGarddatas
      scope.selectSignal = (sig)->
        scope.selectSignals = [sig]
        scope.queryReport()
        $('#mysigs').hide()

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      scope.selectEquipSubscription?.dispose()
      scope.selectEquipSubscription = @commonService.subscribeEventBus 'selectEquip',(msg)=>
        scope.multiflag = false
        scope.selectedEquips = [msg.message]
        scope.selectedEquips = _.filter scope.selectedEquips,(item)=>
          item.level == 'equipment'
        loadEquipmentAndSignals scope.selectedEquips,(data)=>
#            如果是单个设备 data(scope.signals)就是此设备的所有信号
          scope.selectSignals = [scope.signals[0]]
          #          选中设备后自动查询当天的数据
          if scope.selectSignals.length
            scope.queryReport()

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

      scope.queryReport = (page=1,pageItems=scope.parameters.pageItems)=>
        return if checkFilter()
        if scope.selectSignals[0]
          filter ={}
          filter["$or"] = _.map scope.selectedEquips,(equip) -> return {station:equip.station,equipment:equip.id}
          filter.startTime = scope.query.startTime
          filter.endTime = scope.query.endTime
          filter.user = scope.selectSignals[0].model.user
          filter.project = scope.selectSignals[0].model.project
          filter.signal = scope.selectSignals[0].model.signal
#          filter.mode= {"$nin":["communication","event"]}
          filter.mode= {"$nin":["event"]}
          paging =
            page: page
            pageItems: pageItems
          data =
            filter: filter
            paging: paging
            sorting: {station:1,equipment:1,timestamp:1}

          @commonService.reportingService.querySignalRecords data,(err,records,paging2) =>
            return console.log('err:',err) if err

            pCount = paging2?.pageCount or 0
            if pCount <= 6
              paging2?.pages = [1..pCount]
            else if page > 3 and page < pCount-2
              paging2?.pages = [1, page-2, page-1, page, page+1, page+2, pCount]
            else if page <=3
              paging2?.pages = [1, 2, 3, 4, 5, 6, pCount]
            else if page >= pCount-2
              paging2?.pages = [1, pCount-5, pCount-4, pCount-3, pCount-2, pCount-1, pCount]
            scope.pagination = paging2
            dataArray = records
            if !dataArray.length
              scope.barlinevalue = []
              scope.garddatas = []

            else
              if dataArray[0].dataType in ['json','string']
                formatData dataArray,(d)=>
                  #得到格式化报表数据和图表数据
                  scope.garddatas = d
                  scope.$applyAsync()
              else
                @display('此报表仅支持数字数据信号查询！',500)

      formatData=(records,callback) ->
        finalData = null
        index = 0

#        manualGarddatas = [
#          {index:"暂无数据",stationName:"暂无数据",equipmentName:"暂无数据",signalName:"",vSignalName:"",value:"",text:"",user:"",sampleTime:""}
#        ]
#        if scope.selectSignals[0].model.signal == "manual-describe"
#          scope.headers = manualHeaders
#          finalData = _.map records, (record) =>
#            _.extend record, {index:index+1,stationName:getStationName(record.station),equipmentName:getEquipmentName(record.station+"."+record.equipment),value: record.value.mvalue,text:record.value.desc,user:record.user,vSignalName:record.value.name,signalName:getSignalName(record.signal),sampleTime:moment(record.timestamp).format("YYYY-MM-DD HH:mm:ss")}
#            index++
#            if index == records.length
#              callback? records
#        else

        newRecords = _.filter records,(item)=>
          typeof item.value == 'string'
        finalData = _.map newRecords, (record) =>
          url = record.value?.url ? record.value
          _.extend record, {index:index+1,stationName:getStationName(record.station),equipmentName:getEquipmentName(record.station+"."+record.equipment),value: url,signalName:getSignalName(record.signal),sampleTime:moment(record.timestamp).format("YYYY-MM-DD HH:mm:ss")}
          index++
          if index == records.length
            callback? records
      scope.hidemodal = ()=>
        $('#stream-chart-modal').modal('close')
      scope.lookStreamChart = (item) =>
        if scope.currentItem?.signal == item.signal && scope.currentItem?.value == item.value && scope.currentItem?.sampleTime == item.value
          scope.clickFlag = true
        else
          scope.clickFlag = false
        scope.currentItem = item
        str = item.signal.split('-')
        if str.length>1 && str[1] == 'data'
          if str.length == 3
            scope.chartModal = 1
          else
            scope.chartModal = 2
        $('#stream-chart-modal').modal('open')
      scope.downloadStreamFile = (item) =>
        urls = item.value.split(',')
        if urls.length == 1
          window.open(urls[0],'_self')
        else if urls.length == 3
          window.open(urls[0],'_self')
          setTimeout ()=>    #延时10s等待采集完成
            window.open(urls[1],'_self')
            setTimeout =>
              window.open(urls[2],'_self')
            ,3000
          ,4000
      scope.queryPage = (page) ->
        paging = scope.pagination
        return if not paging

        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1

        return if page > paging.pageCount or page < 1
        scope.queryReport page, paging.pageItems

      getStationName=(stationId) ->
        for item in  scope.project.stations.items
          if item.model.station==stationId
            return item.model.name
        return stationId

      getEquipmentName=(equipmentId) ->
        tempEquipment = equipmentId.split('.')
        for item in scope.equipments
          if item.model.equipment == tempEquipment[1] && item.model.station == tempEquipment[0]
            return item.model.name
        return equipmentId

      getSignalName=(signalId) ->
        for item in scope.signals
          if item.model.signal == signalId
            return item.model.name
        return signalId

      getUnit=(unitid)->
        return '' if not unitid
        for item in scope.project.dictionary?.signaltypes.items
          unitItem = item.model
          if unitItem.type == unitid
            return unitItem.unit
        return unitid

      #      scope.exportReport= (header,name)=>
      #        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
      #        @commonService.publishEventBus "export-report", {header:header, name:reportName}
      scope.exportReport = (header,garddatas,name)=>
#        接收一个数组对象导出xlsx表
        if garddatas[0].stationName && garddatas[0].stationName == '暂无数据'
          return @display "暂无数据，无法导出！"

        if scope.selectSignals[0]?.model.signal == "manual-describe"
          data2 = _.map garddatas,(item)->
            return {"序号":item.index,"项目名称":item.stationName,"设备名称":item.equipmentName,"数据名称":item.signalName,"故障预测":item.vSignalName,"预测值":item.value,"备注":item.text,"操作人":item.user,"采集时间":item.sampleTime}
        else
          data2 = _.map garddatas,(item)->
            return {"序号":item.index,"项目名称":item.stationName,"设备名称":item.equipmentName,"数据名称":item.signalName,"数据值":item.value,"采集时间":item.sampleTime}

        data = data2
        ws = XLSX.utils.json_to_sheet(data)
        wb = XLSX.utils.book_new()
        XLSX.utils.book_append_sheet(wb, ws, "Presidents")
        #      XLSX.writeFile(wb, "sheetjs.xlsx")
        reportName = name+moment().format("YYYYMMDDHHmmss")+".xlsx"
        XLSX.writeFile(wb, reportName)




    resize: (scope)->

    dispose: (scope)->
      scope.timeSubscription?.dispose()
      scope.selectEquipSubscription?.dispose()
  #      scope.checkEquipsSubscription?.dispose()

  exports =
    ReportStreamSignalDirective: ReportStreamSignalDirective