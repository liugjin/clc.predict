###
* File: bar-vertical-stack-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  class BarVerticalStackDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "bar-vertical-stack"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      option = {
        tooltip: {
            trigger: 'axis'
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
        series: [
            {
                name: '',
                type: 'bar',
                barWidth: 20,
                stack: 'vertical',
                data: [0, 0],
                itemStyle: {
                  normal: {
                    color: '#7E47FF'
                  },
                  emphasis: {
                    color: '#7E47FF'
                  }
                }
            },
            {
                name: '',
                type: 'bar',
                stack: 'vertical',
                data: [0, 0],
                itemStyle: {
                  normal: {
                    color: '#FD5916'
                  },
                  emphasis: {
                    color: '#FD5916'
                  }
                }
            },
            {
                name: '',
                type: 'bar',
                stack: 'vertical',
                data: [0, 0],
                itemStyle: {
                  normal: {
                    color: '#01A4F7'
                  },
                  emphasis: {
                    color: '#01A4F7'
                  }
                }
            }
        ]
      }
      dom = element.find(".bar-vertical-stack")[0]
      scope.echart = new echart.init(dom)
      scope.element = element

      colorArr = ['#7E47FF', '#FD5916', '#01A4F7']

      # 接参格式： [ { id: "task-defect", key: "故障工单", stack: "故障设备排行前十", val: 0, sort: 0 } ]
      scope.$watch("parameters", (param) => (
        data = param.data
        show = param.show
        return if !show
        # 控制高宽自适应
        width = $($(element).parent()[0]).innerWidth()
        height = $($(element).parent()[0]).innerHeight()
        scope.echart.resize({ width, height })
        
        # 数据处理
        groups = _.map(_.groupBy(data, (d) -> d.stack), (d, stack) -> stack)
        option.xAxis.data = groups

        option.series = _.map(_.groupBy(data, (d) -> d.sort), (g, index) => (
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


    resize: (scope) -> 
      width = $($(scope.element).parent()[0]).innerWidth()
      height = $($(scope.element).parent()[0]).innerHeight()
      scope.echart.resize({
        width, height
      })

    dispose: (scope)->


  exports =
    BarVerticalStackDirective: BarVerticalStackDirective