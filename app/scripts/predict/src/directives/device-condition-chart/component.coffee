###
* File: device-condition-chart-directive
* User: David
* Date: 2019/11/08
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class DeviceConditionChartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-condition-chart"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      drawChart = () => (
        option = {
          # animation: false,
          title: {
            textAlign: "center"
            # position:"center",
            text: scope.parameters.deviceCount,
            left: "49%",
            top: "43%",
            textStyle: {
              color: "#ffffff",
              fontWeight: 400,
              fontSize: 24,
              fontFamily: "PingFangSC-Regular"
            },
            subtext: "总设备数"
            subtextStyle: {
              color: "#ffffff",
              fontWeight: 400,
              fontSize: 14,
              fontFamily: "PingFangSC-Regular"
            }
          },
          label: {
            formatter: "{b|{b}}\n{c|{c}}",
            rich: {
              b: {
                fontSize: 14,
                lineHeight: 30
              },
              c: {
                fontSize: 24,
                align: "right"
              }
            }
          }
          series: [{
            type: 'pie',
            center: ["50%", "50%"]
            radius: ["40%", "70%"]
            data: [{
              name: "健康运行设备数",
              value: scope.parameters.healthCount,
              itemStyle: {
                color: "#55BDFF"
              }
            },
            {
              name: "出现故障设备数量"
              value: scope.parameters.alarmCount,
              itemStyle: {
                color: "#7EDDD9"
              }
            }]
          }]
        }
        scope.myChart.setOption(option);
      )
      init = () => (
        scope.myChart = echarts.init(element.find(".device-condition-chart")[0])
        scope.$watch "parameters", (params) =>
          drawChart()
      )
      init()
    resize: (scope)->
      scope.myChart.resize()

    dispose: (scope)->
      scope.subAlarmInfo?.dispose()


  exports =
    DeviceConditionChartDirective: DeviceConditionChartDirective