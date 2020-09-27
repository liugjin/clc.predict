###
* File: bar-vertical-stack2-directive
* User: David
* Date: 2020/02/17
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  class BarVerticalStack2Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "bar-vertical-stack2"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      option = {
        tooltip: {
            trigger: 'axis',
            axisPointer: {
              type: "none"
            }
        },
        xAxis: {
            axisLine: {
                show: false
            },
            axisTick: {
                show: false
            },
            axisLabel: {
                color: "white",
                fontSize: 16
            },
            type: 'category',
            data: []
        },
        yAxis: {
            show: false,
            type: 'value'
        },
        series: []
      }
      dom = element.find(".bar-vertical-stack2")[0]
      scope.echart = new echart.init(dom)
      scope.element = element

      colorArr = ['#7E47FF', '#FD5916', '#01A4F7']

      # 接参格式： [ { id: "task-defect", key: "故障工单", stack: "故障设备排行前十", val: 0, sort: 0 } ]
      scope.$watch("parameters.data", (data) => (
        
        # 数据处理
        groups = _.map(_.groupBy(data, (d) -> d.stack), (d, stack) -> stack)
        
        option.xAxis.data = groups
        sortList = _.groupBy(data, (d) -> d.sort)

        if option.series.length != sortList.length
          scope.echart.clear()

        option.series = _.map(sortList, (g, index) => (
          _data = _.map(_.sortBy(g, (j) => groups.indexOf(j.stack)), (i) -> i.val)
          return {
            name: index,
            type: 'bar',
            stack: 'vertical',
            data: _data,
            barWidth: 20,
            itemStyle: {
              normal: {
                color: colorArr[index]
              },
              emphasis: {
                color: colorArr[index]
              }
            },
            emphasis: {
              label: {
                show: true
                formatter: () => g[0].key + ":" + g[0].val
              }
            }
          }
        ))
        
        option.tooltip.formatter = (n) => (
          html = n[0].name
          _.each(n, (p) => 
            item = _.find(data, (q) => q.stack == n[0].name && p.seriesIndex == q.sort)
            html += ("<br />" + p.marker + item.key + ": " + item.val)
          )
          return html
        )
        
        scope.echart.setOption(option)
      ))

    resize: (scope) -> scope.echart.resize()

    dispose: (scope)->


  exports =
    BarVerticalStack2Directive: BarVerticalStack2Directive