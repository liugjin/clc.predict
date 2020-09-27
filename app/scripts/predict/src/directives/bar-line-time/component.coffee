###
* File: bar-line-time-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  class BarLineTimeDirective extends base.BaseDirective

    option = {
      tooltip : {
        trigger: "axis",
        padding: [4, 8]
      },
      legend: { selectedMode: false, data: [], right: 0, textStyle: { color: "rgb(167, 182, 204)" } },
      grid: {
        right: 30, bottom: 30, left: 30
      },
      xAxis : {
        type : 'category',
        data : [],
        axisLabel: { color: "rgb(162, 202, 248)" },
        axisLine: { lineStyle: {color: "rgba(0, 77, 160)"} },
        splitLine: { show: false }
      },
      yAxis : [{ 
        type : 'value', scale: true, min: 0, max: 200, 
        axisLabel: { 
          color: "rgb(162, 202, 248)", interval: 1
        },
        axisLine: { 
          lineStyle: {
            color: "rgba(0, 77, 160)"
          } 
        },
        splitLine: { 
          show: true, 
          lineStyle:{ 
            color: ['rgba(0, 77, 160)'], 
            width: 1, 
            type: 'solid' 
          } 
        }
      }, {
        type : 'value', scale: true, min: 0, max: 50, 
        axisLabel: { 
          color: "rgb(162, 202, 248)"
        },
        axisLine: { 
          lineStyle: {
            color: "rgba(0, 77, 160)"
          } 
        },
        splitLine: { 
          show: true, 
          lineStyle:{ 
            color: ['rgba(0, 77, 160)'], 
            width: 1, 
            type: 'solid' 
          } 
        }
      }],
      series : []
    }

    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "bar-line-time"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      multiple = 1
      scope.chart = new echart.init(element.find(".bar-line-canvas")[0])
      scope.chart.on 'click', (params) =>
        console.info params
        if params?.seriesType == "bar"
          @publishEventBus "showrings-plantask", {id:"allplantasks"}
        else if params?.seriesType == "line"
          @publishEventBus "showrings-plantask", {id:"allworkitems"}

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
        option.tooltip.formatter = (d) => (
          html = d[0].name + "<br />"
          _.each(d, (n) =>
            if n.seriesName != "background"
              html += n.marker + n.seriesName + ": " + n.data + "<br />"
          )
          return html
        ) 
        option.xAxis.data = dates
        _data = param.data
        # 1. 取出两个系列的最大值, 然后向上取整
        countMax = _.mapObject(_.groupBy(_data, (d) -> d.key), (n) => 
          max = _.max(n, (m) -> m.val).val
          if max < 10
            return 10
          return Math.ceil(max / 50) * 50
        )
        option.yAxis[0].max = if countMax.bar then countMax.bar else 500
        option.yAxis[0].interval = if countMax.bar then countMax.bar / 5 else 100
        option.yAxis[1].max = if countMax.line then countMax.line else 50
        option.yAxis[1].interval = if countMax.bar then countMax.line / 5 else 10
        # 2. 获得两个系列的倍数
        if _.has(countMax, "bar") && _.has(countMax, "line") && countMax?.line > 0
          multiple = countMax.bar / countMax.line
        else 
          multiple = 1
        # 3. 获取seriesData
        seriesData = _.map(param.series, (s) => {
          type: s.key,
          name: s.name,
          data: getSeriesData(_data, dates, s.key),
          color: s.color
        })
        _.each(seriesData, (item, index) =>
          if item.type == "bar"
            seriesData[index].stack = 'bar'
            seriesData.push({
              name: "background",
              type:'bar',
              color: "rgba(120, 139, 221, 0.6)",
              stack: 'bar',
              data: _.map(item.data, (d) => countMax.bar - d),
              barWidth: "50%"
            })
          else if item.type == "line"
            seriesData[index].data = _.map(item.data, (d) => multiple * d)
        )
        option.series = seriesData
        option.legend.data = _.map(param.series, (d) -> 
          item = { 
            name: d.name, 
            textStyle: { color: d.color }
          }
          item.icon = "circle" if d.key == "bar"
          return item
        )
        option.tooltip.formatter = (d) => (
          html = d[0].name + "<br />"
          html += d[0].marker + d[0].seriesName + ":" + d[0].value + "<br />"
          html += d[1].marker + d[1].seriesName + ":" + d[1].value / multiple
          # console.log(d);
          return html
        )
        scope.chart.setOption(option)
      )

      scope.$watch("parameters", (param) =>
        return if !param
        updateChart(option, param)
      )

    resize: (scope) -> scope.chart.resize()

    dispose: (scope)->


  exports =
    BarLineTimeDirective: BarLineTimeDirective