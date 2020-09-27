###
* File: transverse-bar-directive
* User: David
* Date: 2019/12/30
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  option = {
    color: [
      new echart.graphic.LinearGradient(0, 0, 1, 0, [ { offset: 0, color: 'rgb(85, 151, 252)' }, { offset: 1, color: 'rgb(126, 223, 215)' } ])
    ],
    grid: {
      left: '8%',
      top: '8%',
      right: '10%',
      bottom: '8%',
      containLabel: true
    },
    xAxis: { show: false },
    yAxis: {
      axisTick: 'none',
      axisLine: 'none',
      axisLabel: {
        textStyle: {
          color: '#ffffff',
          fontSize: '16',
        }
      },
      data: []
    },
    series: [{
      type: 'bar',
      yAxisIndex: 0,
      data: [],
      label: {
          normal: {
              show: true,
              position: 'right',
              textStyle: {
                  color: '#ffffff',
                  fontSize: '16',
              }
          }
      },
      barWidth: 12,
      z: 2
    }]
  }
  
  class TransverseBarDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "transverse-bar"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.barChart = echart.init(element.find(".transverse-bar")[0])

      drawChart = (data) => (
        option.yAxis.data = _.map(data, (d) -> d.key)
        option.series[0].data = _.map(data, (d) -> d.val)
        scope.barChart.setOption(option)
      )

      scope.$watch("parameters.data", (data) => (
        return if !data
        drawChart(data)
      ))

    resize: (scope) -> scope.barChart.resize()

    dispose: (scope)->


  exports =
    TransverseBarDirective: TransverseBarDirective