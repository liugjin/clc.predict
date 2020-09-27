###
* File: show-lines-directive
* User: David
* Date: 2019/12/28
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "echarts"], (base, css, view, _, echart) ->
  option = {
    color: ["#00BFFF", "#2CD057"],
    grid: { right: 30, bottom: 30, left: 30 },
    tooltip: {
      trigger: "axis",
      show: true,
      padding: [4, 8]
    },
    xAxis: {
      type: 'category',
      boundaryGap : false,
      data: [],
      axisLabel: {
        color: "rgb(162, 202, 248)"
      },
      axisLine: {
        lineStyle: {color: "rgba(0, 77, 160)"}
      },
      splitLine: { show: false }
    },
    yAxis: [{
      type: 'value', 
      scale: true, 
      max: 500, 
      min: 0,
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
    }, {
      type: 'value', 
      scale: true, 
      max: 50, 
      min: 0,
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
    }],
    series: []
  }
  
  class ShowLinesDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "show-lines"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.lineChart = echart.init(element.find(".canvas-lines")[0])
      map = [
        ["#00BFFF", "#00bfffcc", "#00bfff1a"],
        ["#2CD057", "#2cd057cc", "#2cd0571a"]
      ]

      nameMap = {}
      getSeries = (d, i, count) => (
        nameMap[d.key] = d.name
        series = {
          name: d.key,
          showSymbol: false,
          data: _.map([1..count], (d) -> 0),
          type: 'line',
          smooth: true,
          lineStyle: { color: map[i][0] },
          areaStyle: {
            color: {
              type: 'linear',
              x: 0, y: 0, x2: 0, y2: 1,
              colorStops: [
                { offset: 0, color: map[i][1] }, 
                { offset: 1, color: map[i][2] }
              ],
              global: false
            }
          }
        }
        return series
      )
      
      scope.$watch("parameters", (param) => (
        return if !param
        option.xAxis.data = param.date
        option.series = _.map(param.series, (d, i) => getSeries(d, i, param.date.length))

        # 1. 取出两个系列的最大值, 然后向上取整
        _data = param.data
        countMax = _.mapObject(_.groupBy(_data, (d) -> d.key), (n) => 
          max = _.max(n, (m) -> m.val).val
          if max < 10
            return 10
          return Math.round(max / 100) * 100
        )
        option.yAxis[0].max = if countMax[option.series[0].name] then countMax[option.series[0].name] else 500
        option.yAxis[1].max = if countMax[option.series[1].name] then countMax[option.series[1].name] else 50
        # 2. 获得两个系列的倍数
        multiple = option.yAxis[0].max / option.yAxis[1].max
        
        _.each(option.series, (series, index) =>
          option.series[index].data = _.map(param.date, (m) => 
            item = _.find(param.data, (d) => d.key == series.name && d.time == m)
            return if item then item.val else 0
          )
        )
        option.tooltip.formatter = (d) => (
          html = d[0].name + "<br />"
          _.each(d, (n) =>
            html += n.marker + nameMap[n.seriesName] + ": " + n.data + "<br />"
          )
          return html
        )
        scope.lineChart.setOption(option)
      ))

    resize: (scope) -> scope.lineChart.resize()

    dispose: (scope) ->


  exports =
    ShowLinesDirective: ShowLinesDirective