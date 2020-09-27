###
* File: failure-rank-chart-directive
* User: David
* Date: 2019/11/11
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class FailureRankChartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "failure-rank-chart"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 画图表
      drawChart = () => (
        equipmentAllName = []
        equipmentAllValue = []
        decorateData = []
        _.each scope.tenFailureDevice, (item) -> (
          equipmentAllName.push(item._id.stationName + "." + item._id.equipmentName)
          equipmentAllValue.push(item.failureRate)
          decorateData.push(100)
        )
        option = {
          animation: false,
          grid: {
            left: "5%",
            right: "4%",
            bottom: "18%",
            top: "10%"
          },
          xAxis: {
            data: equipmentAllName,
            axisLabel: {
              color: "#fff",
              rotate: 15
            },
            axisLine: {
              lineStyle: {
                color: "#004DA0"
              }
            }
          },
          yAxis: {
            axisLabel: {
              color: "#A2CAF8",
              formatter: "{value}%"
            },
            axisLine: {
              lineStyle: {
                color: "transparent"
              }
            },
            splitLine: {
              lineStyle: {
                color: "#004DA0"
              }
            }
          },
          series: [
            # 装饰
            {
              type: 'bar',
              barWidth: 34,
              barGap: '-100%',
              data: decorateData
              color: "rgba(170, 201, 244, 0.3)",
              label: {
                normal: {
                  show: true,
                  position: "top",
                  distance: 10,
                  color: "#fff"
                  formatter: (params)->
                    return (equipmentAllValue[params.dataIndex] - 0.5).toFixed(2) + "%"
                }
              }
            },
            # 数据在这里
            {
              type: 'bar',
              data: equipmentAllValue,
              barWidth: 34,
              itemStyle: {
                color: {
                  type: 'linear',
                  x: 0,
                  y: 0,
                  x2: 0,
                  y2: 1,
                  colorStops: [
                    { offset: 0, color: "#7EDFD7" },
                    { offset: 1, color: '#5597FC' }
                  ],
                }
              }
            }
          ]
        };
        scope.myChart.setOption(option);
      )
      # 处理故障率数据
      processFailureData = () => (
        addNoAlarmDevice = () => (
          _.each scope.equipments, (equipment) -> (
            if whenStop != addDeviceCount
              if equipment.state == 0
                whenStop++
                tenFailureDevice.push(
                  {
                    failureRate: 0.5,
                    total_events: 0,
                    _id: {
                      equipment: equipment.model.equipment,
                      equipmentName:equipment.model.name
                      stationName:equipment.model.stationName
                      equipmentType: equipment.model.type
                    }
                  }
                )
          )
        )
        tenFailureDevice = _.sortBy scope.eventAlarmInfo, (item)->
                return -item.failureRate

#        tenFailureDevice.reverse()
        tenFailureDevice = tenFailureDevice.slice(0, 10)
        addDeviceCount = 0
        whenStop = 0
        if tenFailureDevice.length < 10
          if scope.allDeviceCount >= 10
            addDeviceCount = 10 - tenFailureDevice.length
            addNoAlarmDevice()
          else if scope.allDeviceCount < 10
            addDeviceCount = scope.allDeviceCount - tenFailureDevice.length
            addNoAlarmDevice()
        scope.tenFailureDevice = tenFailureDevice

        drawChart()
      )
      # 统计每个设备的故障率
      statisticalEquipmentFailure = () => (
        aggregateCons = []
        matchObj = {}
        groupObj = {}
        filter = scope.project.getIds()
        matchObj.$match = filter
        groupObj.$group = {_id:{equipmentType:"$equipmentType",station:"$station",equipment:"$equipment",stationName:"$stationName",equipmentName:"$equipmentName"},total_events:{$sum:1}}
        aggregateCons.push matchObj
        aggregateCons.push groupObj
        @commonService.reportingService.aggregateEventValues {filter:@project.getIds(),pipeline:aggregateCons,options:{allowDiskUse:true}}, (err, records) =>
          if records
            scope.eventAlarmInfo = []
            scope.eventAlarmCount = 0
#            _.each records , (record) -> (
#              _.each scope.equipments, (equipment) -> (
#                if equipment.model.equipment == record._id.equipment && equipment.model.station == record._id.station
#                  scope.eventAlarmCount = scope.eventAlarmCount + record.total_events
#                  scope.eventAlarmInfo.push(record)
##              )
#            )

            _.each records,(record)->
              scope.eventAlarmCount = scope.eventAlarmCount + record.total_events
              scope.eventAlarmInfo.push(record)

            _.each scope.eventAlarmInfo , (record)-> (
              record.failureRate = Number(((record.total_events / scope.eventAlarmCount) * 100 + 0.5).toFixed(2))
            )
          processFailureData()
      )
      init = () => (
        scope.tenFailureDevice = []
        scope.allDeviceCount = 0
        scope.equipments= []
        scope.eventAlarmInfo = []
        scope.myChart = echarts.init($(".failure-rank-chart")[0])
        scope.eventAlarmCount = 0
        stationsCount = scope.project.stations.items.length
        _.each(scope.project.stations.items, (station)->
          station.loadEquipments {}, null, (err, equips) ->
            stationsCount--
            _.each(equips, (equip)->
              if (equip.model.equipment.indexOf("_") == -1)
                equip.model.stationName = equip.station.model.name
                scope.equipments.push(equip)
            )
            if(stationsCount == 0)
              scope.allDeviceCount = scope.equipments.length
              statisticalEquipmentFailure()
        )
      )
      init()

    resize: (scope)->
      scope.myChart.resize()

    dispose: (scope)->


  exports =
    FailureRankChartDirective: FailureRankChartDirective