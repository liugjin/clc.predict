###
* File: bar-timeline-directive
* User: David
* Date: 2019/12/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define(['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  class BarTimelineDirective extends base.BaseDirective
  
    option = {
      grid: {
        right: 5, bottom: 30, left: 30
      },
      legend: {
        data: [], selectedMode: false,
        top: 10, right: 0, icon: "circle", textStyle: { color: "rgb(167, 182, 204)" }
      },
      tooltip: {
        trigger: "axis",
        padding: [4, 8]
      },
      xAxis: {
        type: 'category',
        data: [],
        axisLabel: {
          color: "rgb(162, 202, 248)"
        },
        axisLine: {
          lineStyle: {color: "rgba(0, 77, 160)"}
        },
        splitLine: { show: false }
      },
      yAxis: {
        axisLabel: {
          color: "rgb(162, 202, 248)"
        },
        axisLine: {
          lineStyle: {color: "rgba(0, 77, 160)"}
        },
        splitLine: {
          show: true,
          lineStyle:{ color: ['rgba(0, 77, 160)'], width: 1, type: 'solid' }
        }
      },
      series: []
    }

    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "bar-timeline"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) => (
      scope.barChart = new echart.init(element.find(".bar-canvas")[0])

      getSeriesData = (data, dates, key) => (
        list = _.map([1..dates.length], (d) -> 0)
        _.each(_.filter(data, (d) => d.key == key), (d) => 
          index = dates.indexOf(d.time)
          list[index] = d.val if index != -1
        )
        return list
      )

      updateChart = (option, param) => (
        dates = param.date
        option.xAxis.data = dates
        scope.data = param.data
        option.series = _.map(param.series, (s) => {
          type: 'bar',
          name: s.name,
          data: getSeriesData(scope.data, dates, s.key),
          color: s.color
        })
        option.legend.data = _.map(param.series, (d) -> d.name)
        scope.barChart.setOption(option)
      )

      scope.$watch("parameters", (param) =>
        return if !param
        updateChart(option, param)
      )
    )

    resize: (scope) -> scope.barChart.resize()

    dispose: (scope) ->

  exports = { BarTimelineDirective: BarTimelineDirective }
)    