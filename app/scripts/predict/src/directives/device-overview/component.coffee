###
* File: device-overview-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceOverviewDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-overview"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.allDeviceNumber = 0 #投放所有的设备数量
      scope.seriesData = []
      @getDeviceType(scope)
    getDeviceType:(scope)=>
      # 获取所有站点
      scope.project.loadStations null, (err, stations)=>
        scope.stations = stations
      # 获取设备类型
      scope.deviceType = scope.project.typeModels.equipmenttypes.items
      for dev in scope.deviceType
        if(dev.model.type == "forecast")
          scope.categories = dev.categories
      for cate in scope.categories
        typeModel = {name:"",type:"",model:[],imgUrl:""}
        typeModel.name = cate.model.name
        typeModel.type = cate.model.type
        typeModel.imgUrl =  "#{@getComponentPath('images/'+cate.model.type+".svg")}"
        scope.seriesData.push(typeModel)
      @getequips(scope,scope.stations)
    # 获取指定类型的设备集合
    getequips:(scope,stations)=>
      for sta in scope.stations
        for cate in scope.categories
          @commonService.loadEquipmentsByType sta, cate.model.type, (err, equips)=>
            @settypeNum(scope,equips)
    # 设置每种类型的设备数量
    settypeNum:(scope,equips)=>
      i= 0
      for eq in equips
        for ser in scope.seriesData
          if(eq.model.type == ser.type)
            ser.model.push(eq)
      for ser in scope.seriesData
        i += ser.model.length
      scope.allDeviceNumber = i
# 小于2位数前面补0
    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num

    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()


  exports =
    DeviceOverviewDirective: DeviceOverviewDirective