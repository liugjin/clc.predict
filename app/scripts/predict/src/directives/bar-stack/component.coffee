###
* File: bar-stack-directive
* User: David
* Date: 2019/12/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  
  class BarStackDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "bar-stack"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      option = {
        tooltip: {
          trigger: "axis",
          show: true
        },
        grid: {
          containLabel: true,
          left: 0,
          right: 15,
          bottom: 30
        },
        xAxis: {
          splitNumber: 5,
          interval: 20,
          max: 100,
          axisLabel: {
            show: false
          },
          axisLine: {
            show: false
          },
          axisTick: {
            show: false
          },
          splitLine: {
            show: false
          }

        },
        yAxis: [{
            data: ['待处理工单', '异常设备'],
            axisLabel: {
              fontSize: 16,
              color: '#fff'

            },
            axisLine: {
              show: false
            },
            axisTick: {
              show: false
            },
            splitLine: {
              show: false
            }
          }, {
            show: false,
            data: ['待处理工单', '异常设备'],
            axisLine: {
              show: false
            }
          }
        ],
        series: [{
            type: 'bar',
            name: '',
            stack: '2',
            barWidth: 20,
            itemStyle: {
              normal: {
                color: '#7E47FF'
              },
              emphasis: {
                color: '#7E47FF'
              }
            },
            data: [0, 0]
          }, {
            type: 'bar',
            name: '',
            stack: '2',
            barWidth: 20,
            itemStyle: {
              normal: {
                color: '#FD5916'
              },
              emphasis: {
                color: '#FD5916'
              }
            },
            data: [0, 0]
          }, {
            type: 'bar',
            stack: '2',
            name: '',
            barWidth: 20,
            itemStyle: {
              normal: {
                color: '#01A4F7'
              },
              emphasis: {
                color: '#01A4F7'
              }
            },
            data: [0, 0]
          }
        ]
      }

      scope.echart = new echart.init(element.find(".bar-stack")[0])

      scope.echart.on 'click', (params) =>
        if params.name == "待处理工单"
          @publishEventBus "component-totaltask-handingsheets", {id:"component-totaltask-handingsheets"}
        else if params.name == "异常设备"
          @publishEventBus "component-totaltask-excepequips", {id:"component-totaltask-excepequips"}

      colorArr = ['#7E47FF', '#FD5916', '#01A4F7']

      sumBy = (list, key) => (
        sum = 0
        _.each(list, (d) => sum += d[key])
        return sum
      )

      scope.$watch("parameters.data", (data) => (
        # 控制高宽自适应
        width = $($(element).parent()[0]).innerWidth()
        height = $($(element).parent()[0]).innerHeight()
        scope.echart.resize({ width, height })

        # 数据处理
        groups = _.map(_.groupBy(data, (d) -> d.stack), (d, stack) -> stack)
        max = sumBy(data, "val")
        option.xAxis.max = if max > 0 then max else 1
        option.yAxis[0].data = groups
        option.yAxis[1].data = groups

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
    BarStackDirective: BarStackDirective