###
* File: ring-layers-directive
* User: David
* Date: 2019/12/30
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echart) ->
  option = {
    legend: { show: true, bottom: 10, icon: "circle", textStyle: { color: "rgb(167, 182, 204)" } },
    tooltip: { show: true },
    series: [
      {
        type: 'pie',
        radius: ['65%', '75%'],
        center: ['50%', '40%'],
        hoverAnimation: false,
        z: 10,
        label: {
          position: 'center',
          formatter: () => '',
          color: '#7a8c9f',
          fontSize: 16,
          lineHeight: 30,
        },
        data: [],
        labelLine: { show: false }
      }, {
        type: 'pie',
        radius: ['54%', '64%'],
        center: ['50%', '40%'],
        hoverAnimation: false,
        label: { show: false },
        data: [],
        labelLine: { show: false }
      }, {
        type: 'pie',
        radius: ['43%', '53%'],
        center: ['50%', '40%'],
        hoverAnimation: false,
        label: { show: false },
        data: [{
            value: 0,
            name: '',
            itemStyle: { color: '#0286ff', opacity: 0.1 }
          }, {
            value: 0,
            name: '',
            itemStyle: { color: '#ffd302', opacity: 0.1 }
          }, {
            value: 0,
            name: '',
            itemStyle: { color: '#fb5274', opacity: 0.1 }
        }],
        labelLine: { show: false }
      }
    ]
  }
  class RingLayersDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "ring-layers"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.ringChart = echart.init(element.find(".ring-layers")[0])

      scope.$watch("parameters", (param) => (
        return if !param
        map = [0.9, 0.4, 0.1]
        _.each(option.series, (series, index) => (
          option.series[index].data = _.map(param.data, (d) -> {
            value: 0,
            name: d.key,
            itemStyle: { color: d.color, opacity: map[index] }
          })
        ))
        scope.ringChart.setOption(option)
      ))

    resize: (scope)->

    dispose: (scope)->


  exports =
    RingLayersDirective: RingLayersDirective