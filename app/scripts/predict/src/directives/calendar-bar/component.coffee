###
* File: calendar-bar-directive
* User: David
* Date: 2020/01/08
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  
  class CalendarBarDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "calendar-bar"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      option = {
        color: ["#3b99ff", "#174c90", "transparent"],
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        series: [{
          name: '',
          type: 'pie',
          clockwise: false,
          radius: ['60%', '80%'],
          avoidLabelOverlap: false,
          label: {
            position: 'inner',
            color: "white"
          },
          # labelLine: {
          #   normal: {
          #     show: false
          #   }
          # },
          data: []
        }, {
          name: '',
          type: 'pie',
          radius: '40%',
          label: {
            normal: {
              show: true,
              position: 'center',
              rich: {
                  title: {
                      color: '#8d9fbe',
                      fontSize: 14
                  },
                  value: {
                      color: 'white',
                      fontSize: 14
                  }
              }
            }
          },
          labelLine: {
            show: false
          },
          data: [{ name: "总量", value: 0 }]
        }]
      };
      scope.chart = echart.init(element.find(".calendar-bar")[0])

      scope.chart.on("click", (e) => @commonService.publishEventBus("orderType", e))

      update = (param) =>
        sum = 0
        _.each(param.data, (d) => sum += d.value)
        option.series[0].data = param.data
        option.series[1].label.normal.formatter = (d) => '{title|' + d.seriesName + '}\n\n{value|' + sum + '}'
        option.series[1].data[0].value = sum
        scope.chart.setOption(option)
        scope.$applyAsync()

      scope.$watch("parameters", (param) =>
        return if !param
        series = option.series[0]
        if series.name != param.title
           option.series[0].name = param.title 
           option.series[1].name = param.title 
        if (series.data.length == 0)
          update(param)
        else if (param.data[0].value != series.data[0].value or param.data[1].value != series.data[1].value)
          update(param)
      )

    resize: (scope) -> scope.chart.resize()

    dispose: (scope)->


  exports =
    CalendarBarDirective: CalendarBarDirective