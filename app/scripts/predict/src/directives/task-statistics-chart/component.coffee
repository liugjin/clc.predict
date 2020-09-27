###
* File: task-statistics-chart-directive
* User: David
* Date: 2019/08/28
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class TaskStatisticsChartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "task-statistics-chart"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.ng = {
        myCharts: null,
      }
      drawCharts = () -> (
        scope.ng.myCharts = echarts.init $(element).find('.my-charts')[0]
        option = {
          title:
            x: "47%",
            y: "45%",
            textAlign: "center",
            top: "70%",
            text: scope.parameters.name,
            textStyle:
              fontWeight: "bold",
              color: "#ffffff",
              fontSize: 14
          series:[
            {
              name: "",
              type: "pie",
              center: ["50%", "45%"],
              radius: ["50%", "70%"],
              color: [scope.parameters.barColor, "transparent"],
              hoverAnimation: true,
              legendHoverLink: false,
              z: 10,
              labelLine: {
                normal: {
                  show: false
                }
              },
              data: [{
                value: scope.parameters.value,
                label: {
                  normal: {
                    formatter: scope.parameters.value.toString(),
                    position: "center",
                    show: true,
                    textStyle: {
                      fontSize: "24",
                      fontWeight: "normal",
                      color: "#fff"
                    }
                  }
                }
              }, {
                value: scope.parameters.total - scope.parameters.value
              }]
            },
#          装饰
            {
              name: "",
              type: "pie",
              center: ["50%", "45%"],
              radius: ["55%", "65%"],
              silent: true,
              labelLine: {
                normal: {
                  show: false
                }
              },
              z: 5,
              data: [{
                value: 100,
                itemStyle: {
                  color: "rgba(108,228,236,0.1)",

                }
              }]
            }
          ]
        }
        scope.ng.myCharts.setOption option
      )
      init = () =>
        return if not scope.firstload
        scope.ng.myCharts = echarts.init $(element).find('.my-charts')[0]
        scope.ng.myCharts.on("click",(e)=>
          @commonService.publishEventBus("orderType", scope.parameters.name)
        )
        scope.$watch 'parameters', (data) ->
          drawCharts()
      init()


    resize: (scope)->
      scope.ng.myCharts.resize()

    dispose: (scope)->


  exports =
    TaskStatisticsChartDirective: TaskStatisticsChartDirective