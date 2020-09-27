###
* File: show-rings-directive
* User: David
* Date: 2019/12/28
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  class ShowRingsDirective extends base.BaseDirective
    option = {
      color: [],
      tooltip: {
        padding: [4, 8],
        show: true,
        trigger: "item", 
        icon: "circle"
      },
      grid: {
        top: '10%',
        bottom: '58%',
        left: "53%",
        containLabel: false
      },
      yAxis: [{
        offset: 12,
        type: 'category',
        inverse: true,
        axisLine: {
          show: false
        },
        axisTick: {
          show: false
        },
        axisLabel: {
          interval: 0,
          inside: true,
          textStyle: {
            color: "white",
            fontSize: 14,
          },
          show: true
        },
        data: []
      }],
      xAxis: [{
        show: false
      }],
      series: []
    }
    
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "show-rings"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      scope.ringChart = new echart.init(element.find(".ring-canvas")[0])
      scope.ringChart.on 'click', (params) =>
        if params?.seriesName == "execepequips"
          @publishEventBus "showrings-plantask", {id:"execepequips"}
        else if params?.seriesName == "allworkitems"
          @publishEventBus "showrings-plantask", {id:"allworkitems"}
        else if params?.seriesName == "handling"
          @publishEventBus "showrings-plantask", {id:"handling"}


      colorArr = [
        new echart.graphic.LinearGradient(0, 0, 0, 1, [{offset: 0, color: '#75EA81'}, {offset: 1, color: '#2DA0E1'}]),
        new echart.graphic.LinearGradient(0, 0, 0, 1, [{offset: 0, color: '#3DFFE1'}, {offset: 1, color: '#2DA0E1'}]),
        new echart.graphic.LinearGradient(0, 0, 0, 1, [{offset: 0, color: '#5597FC'}, {offset: 1, color: '#7EDFD7'}]),
        new echart.graphic.LinearGradient(0, 0, 0, 1, [{offset: 0, color: '#5580FC'}, {offset: 1, color: '#7EDFD7'}])
      ]

      option.color = colorArr if option.color.length == 0

      getSeries = (data) => (
        # sum = 0
        # _.each(data, (d) => sum += d.val)
        series = []
        for i in [0..data.length - 1]
          series.push({
            # name: '',
            name: data[i].type,
            type: 'pie',
            clockWise: false, 
            hoverAnimation: false, 
            radius: [73 - i * 15 + '%', 68 - i * 15 + '%'],
            center: ["50%", "50%"],
            label: { show: false },
            itemStyle: {
              label: { show: false },
              labelLine: { show: false },
              borderWidth: 5
            },
            data: [{
              # value: data[i].val,
              value: 0,
              name: data[i].title
            }, {
              # value: sum - data[i].val,
              value: 0,
              name: '',
              itemStyle: {
                color: "rgba(0,0,0,0)",
                borderWidth: 0
              },
              tooltip: {
                show: false
              },
              hoverAnimation: false
            }]
          });
          series.push({
            name: '',
            type: 'pie',
            silent: true,
            z: 1,
            clockWise: false, 
            hoverAnimation: false, 
            radius: [73 - i * 15 + '%', 68 - i * 15 + '%'],
            center: ["50%", "50%"],
            label: {
              show: false
            },
            itemStyle: {
              label: {
                show: false
              },
              labelLine: {
                show: false
              },
              borderWidth: 5
            },
            data: [{
              value: 7.5,
              itemStyle: {
                color: "rgba(120, 139, 221, 0.3)",
                borderWidth: 0
              },
              tooltip: {
                show: false
              },
              hoverAnimation: false
            }, {
              value: 2.5,
              name: '',
              itemStyle: {
                color: "rgba(0,0,0,0)",
                borderWidth: 0
              },
              tooltip: {
                show: false
              },
              hoverAnimation: false
            }]
          });
        return series;
      )

      drawChart = (param) => (
        # option.tooltip.formatter = (d) => d.name + "<br />实时值: " + d.value + "<br />占比: " + d.percent + "%"
        option.tooltip.formatter = (d) => (
          current = _.find(param.data, (m) => m.type == d.seriesName)
          # console.log(param, d, current)
          return d.name + "<br />实时值: " + current.val
        )
        option.yAxis[0].data = _.map(param.data, (d) -> d.title) 
        option.series = getSeries(param.data)
        scope.ringChart.setOption(option)
      )

      scope.$watch("parameters", (param) => (
        return if !param
        # console.log("环形图", param)
        # param.data = [
        #   {type: "allworkitems", title: "巡检项总数: 0: 0", val: 2, peresent: 0},
        #   {type: "handling", title: "待处理工单数: 0: 0", val: 5, peresent: 0},
        #   {type: "execepequips", title: "异常巡检点: 0: 0", val: 10, peresent: 0}
        # ]
        drawChart(param)
      ))

    resize: (scope) ->
      scope.ringChart.resize()

    dispose: (scope)->


  exports =
    ShowRingsDirective: ShowRingsDirective