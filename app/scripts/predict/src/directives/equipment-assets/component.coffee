###
* File: equipment-assets-directive
* User: David
* Date: 2020/02/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class EquipmentAssetsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-assets"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      @setData(scope,element)
#    setData:(scope,element)=>
#      scope.seriesData = []
#      scope.equips = []
#      # 获取当前站点的设备类型
#      scope.deviceType = scope.project.typeModels.equipmenttypes.items
#      for dev in scope.deviceType
#        if(dev.model.type == "forecast")
#          for categories in dev.categories
#            @getequips(scope,element,scope.station,categories.model.type,categories)
#    # 获取指定类型的设备集合
#    getequips:(scope,element,station,type,categories)=>
#      @commonService.loadEquipmentsByType station, type, (err, equips)=>
#        typeModel = {value:0,name:""}
#        typeModel.value = @addZero(equips.length)
#        typeModel.name  = categories.model.name
#        scope.seriesData.push typeModel
#        @createLineCharts(scope,element)
#    # 渲染图表
#    createLineCharts: (scope,element) =>
#      line = element.find(".echartsContent")
#      scope.echart?.dispose()
#      option =
#        tooltip:
#          trigger: 'item'
#          formatter: '{b} : {c} ({d}%)'
#        series:[
#          {
#            name: '设备总数',
#            type: 'pie',
#            radius: [36, 75],
#            center: ['50%', '55%']
#            roseType: 'area',
#            data: scope.seriesData
#            itemStyle:
#              normal:
#                color:(params)=>
#                  colorList = ['#00A7FF', '#0089D9', '#00D6FF', '#00FFC0']
#                  return colorList[params.dataIndex]
#            label:
#                color: 'rgba(245,252,255,1)'
#                formatter: '{b|{b}}\n{c|{c}}'
#                rich:
#                  b:
#                    color: "#FFFFFF"
#                    align: "center"
#                    fontSize: 18
#
#                  c:
#                    fontWeight: 600
#                    fontSize: 28
#                    align: "center"
#          }
#        ]
#      scope.echart = echarts.init line[0]
#      scope.echart.setOption option
#
#      scope.resize=()=>
#        @$timeout =>
#          scope.echart?.resize()
#        ,100
#      window.addEventListener 'resize', scope.resize
#      window.dispatchEvent(new Event('resize'))
#
#    # 小于2位数前面补0
#    addZero:(num)=>
#      if (parseInt(num) < 10 and parseInt(num)>0)
#        num = '0' + num
#      return num
    resize: (scope)->

    dispose: (scope)->
#      scope.stationEventBus?.dispose()


  exports =
    EquipmentAssetsDirective: EquipmentAssetsDirective