###
* File: order-situation-directive
* User: David
* Date: 2019/11/07
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class OrderSituationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "order-situation"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      subscribeOrderType = () => (
        scope.subscribeOrderType?.dispose()
        scope.subscribeOrderType = @commonService.subscribeEventBus("orderType", (data)->
          scope.orderType = data.message
          processOrderData()
        )
      )
      # 订阅工单
      subscribeTasks = () => (
        user = scope.$root.user.user
        topic = "tasks/#{user}/#"
        scope.maintasksSubscri?.dispose()
        scope.maintasksSubscri = @commonService.configurationLiveSession.subscribe topic, (err, order) =>
          return if not order
          getTypeOrderTotal()
      )
      # 把数据清空
      clearData = () => (
        scope.typeOrderTotal = 0
        scope.opsMonthFinish = 0
        scope.opsMonthUnfinish = 0
        scope.opsMonthOrder = 0
        scope.opsUnfinish = 0
        scope.secondPieChartCount = 0
        scope.secondPieChartAllCount = 0
        scope.thirdPieChartCount = 0
        scope.thirdPieChartAllCount = 0
      )
      getUnfinishMonthCompletionData = (order,monthStartTime,monthEndTime,orderCreateTime) => (
        lastNode = order.nodes.length - 1
        orderUpdateTime = moment(order.updatetime).format('YYYY-MM-DD hh:mm:ss')
        scope.typeOrderTotal++
          # 获取未完成工单
        if order.nodes[lastNode].state != "approval"
          scope.opsUnfinish++
        # 获取本月工单数,本月已完成工单数,本月未完成工单数
        if (orderUpdateTime >= monthStartTime && orderUpdateTime <= monthEndTime)
          scope.opsMonthOrder++
          if order.nodes[lastNode].state == "approval"
            scope.opsMonthFinish++
          else
            scope.opsMonthUnfinish++
      )
      # 处理工单数据
      processOrderData = () => (
        clearData()
        monthStartTime = moment().startOf('month').format('YYYY-MM-DD ') + "00:00:00"
        monthEndTime = moment().endOf('month').format('YYYY-MM-DD ') + "23:59:59"
        #############################类型为工单概况时#############################
        if scope.orderType == "all"
          scope.showMode = "count"
          scope.secondChartName = "本月设备作业台数"
          scope.threeCheartName = "本月发生异常台数"
          equipments = []
          _.each scope.opsOrder, (order) -> (
            orderCreateTime = moment(order.createtime).format('YYYY-MM-DD HH:mm:ss')
            getUnfinishMonthCompletionData(order,monthStartTime,monthEndTime)
            contents = JSON.parse(order?.nodes[0]?.contents[0]?.content)?.content
            _.each contents, (content) -> (
              equipments = _.filter equipments, (equipment) -> (
                equipment.station != content.station || equipment.equipment != content.equipment
              )
              equipments.push({station: content.station, equipment: content.equipment, createtime: order.createtime})
              # 本月发生异常单数
              if content.status == 1
                scope.thirdPieChartAllCount++
                if(orderCreateTime>=monthStartTime)
                  scope.thirdPieChartCount++
            )
          )
          # 本月设备作业台数
          _.each equipments, (equipment)-> (
            scope.secondPieChartAllCount++
            if moment(equipment.createtime).format('YYYY-MM-DD HH:mm:ss') >= monthStartTime
              scope.secondPieChartCount++
          )
        #############################类型为故障工单时#############################
        else if(scope.orderType == "defect")
          scope.showMode = "percent"
          scope.secondChartName = "本月作业单数"
          scope.threeCheartName = "完成率"
          _.each scope.opsOrder, (order) -> (
            if order.type == scope.orderType
              orderCreateTime = moment(order.createtime).format('YYYY-MM-DD HH:mm:ss')
              getUnfinishMonthCompletionData(order,monthStartTime,monthEndTime,orderCreateTime)
              # 本月作业单数
              scope.secondPieChartAllCount++
              if orderCreateTime >= monthStartTime
                scope.secondPieChartCount++
              # 完成率
              scope.thirdPieChartAllCount++
              if order.phase.nextNode == null
                scope.thirdPieChartCount++
          )
        #############################类型为巡检工单时候#############################
        else if(scope.orderType == "plan")
          scope.showMode = "count"
          scope.secondChartName = "本月作业项"
          scope.threeCheartName = "发生异常设备的数量"
          equipments = []
          allContent = []
          alarmEquipments = []
          _.each scope.opsOrder, (order) -> (
            if order.type == scope.orderType
              orderCreateTime = moment(order.createtime).format('YYYY-MM-DD HH:mm:ss')
              getUnfinishMonthCompletionData(order,monthStartTime,monthEndTime,orderCreateTime)
              contents = JSON.parse(order.nodes[0].contents[0].content).content
              # 本月作业项
              scope.secondPieChartAllCount = scope.secondPieChartAllCount + contents.length
              if(orderCreateTime>=monthStartTime)
                scope.secondPieChartCount = scope.secondPieChartCount + contents.length
              # 发生异常的设备数量
              _.each contents, (content) -> (
                allContent.push content
                equipments = _.filter equipments, (equipment) -> (
                  equipment.station != content.station || equipment.equipment != content.equipment
                )
                equipments.push({station: content.station, equipment: content.equipment, createtime: order.createtime})
              )
          )
          # 发生异常的设备数量
          _.each(allContent, (content) ->
            if content.status == 1
              alarmEquipments.push(content.station + "." + content.equipment)
          )
          alarmEquipments = _.uniq(alarmEquipments)
          scope.thirdPieChartAllCount = equipments.length
          scope.thirdPieChartCount = alarmEquipments.length

      )
      # 获取工单总数
      getTypeOrderTotal = () => (
        filter = scope.project.getIds()
        scope.nowTime = moment().format()
        scope.oneYearAgo = moment(scope.nowTime).subtract(12, 'month').startOf('day').format()
        filter.createtime = {
          "$gte": scope.oneYearAgo,
          "$lte": scope.nowTime
        }
        @commonService.loadProjectModelByService 'tasks', filter, null, (err, data) => (
          if data
            scope.opsOrder = data
            processOrderData()
        )
      )
      # 初始化执行
      init = () => (
        scope.opsOrder = [] # 工单信息
        scope.secondPieChartCount = 0 # 本月设备作业单数
        scope.secondPieChartAllCount = 0 # 本年设备作业单数
        scope.thirdPieChartCount = 0 # 本月发生异常单数
        scope.thirdPieChartAllCount = 0 # 本年发生异常单数
        scope.showMode = "count"
        scope.nowTime = ""
        scope.oneYearAgo = ""
        scope.secondChartName  = "本月设备作业台数"
        scope.threeCheartName = "本月发生异常单数"
        scope.typeOrderTotal = 0 # 切换导航栏时显示的工单总数
        scope.opsUnfinish = 0 # 未完成工单总数
        scope.opsMonthOrder = 0 # 本月工单数
        scope.opsMonthFinish = 0 # 本月已完成工单数
        scope.opsMonthUnfinish = 0 # 本月未完成工单数
        scope.orderType = "all"
        subscribeOrderType()
        getTypeOrderTotal()
        subscribeTasks()
      )
      init()

    resize: (scope)->

    dispose: (scope)->
      scope.maintasksSubscri?.dispose()
      scope.subscribeOrderType?.dispose()


  exports =
    OrderSituationDirective: OrderSituationDirective