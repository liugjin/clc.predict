###
* File: device-predict-directive
* User: David
* Date: 2019/12/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DevicePredictDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-predict"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.parents = []
      scope.project.loadEquipmentTemplates {}, null
      scope.defaultName = "默认场景"
      scope.focus = 3
      scope.showDevice = true

      scope.project.loadStations null, (err, stations)=>
        console.log stations
#        dataCenters = _.filter stations, (sta)->(sta.model.parent is null or sta.model.parent is "") and sta.model.station.charAt(0) isnt "_"
        dataCenters = _.filter stations, (sta)-> sta.model.group isnt "datacenter"
        console.log dataCenters
        scope.stations = dataCenters

        scope.station = dataCenters[0]
        scope.parents = []


      publishEquipmentId = (scope) =>
        scope.templateDatas = {
          equipment: scope.equipment.model?.equipment
          station: scope.equipment.model?.station
        }
        scope.project.loadEquipmentTemplates {template: scope.equipment.model.template}, '', (err, template) =>
          scope.templateId = template[0].model.graphic
          scope.scene = @getComponentPath("./files/"+scope.equipment.model.type+".json")
        @commonService.publishEventBus "equipmentInfo", scope.templateDatas

      showStation = (scope) =>
        scope.parents = []
        filter = if scope.parameters.type then {type: scope.parameters.type} else null
        scope.station.loadEquipments null, null, (err, equips)=>
          return if  err
          filtersEquipment = _.filter equips,(equip)-> equip.model.equipment isnt '_station_management'
          filtersEquipment = _.sortBy filtersEquipment,(item)->item.model._index
          scope.equipments = filtersEquipment

          if not scope.equipment or scope.equipment.model.station isnt scope.station.model.station
            scope.equipment = filtersEquipment?[0]
          publishEquipmentId(scope)
          getTemplates(scope)

#        @findParent scope, scope.station
#        scope.stations = scope.parents[0]?.stations
#        scope.parents = scope.parents.reverse()
# 获取设备模板，并设备筛选对应设备的组态ID 并通过模板ID选择对应的设备3D文件
      getTemplates = (scope)=>
        for tem in scope.equipments
          if tem.model.type == scope.equipment.model.type
            scope.scene = @getComponentPath("./files/"+tem.model.type+".json")
#            console.log scope.scene
            scope.templateId = tem.model.graphic
            clickTime(scope)
      clickTime = (scope) =>
        scope.clickTime=(i)=>
          scope.focus = i
          # 发布主题
          if(scope.focus == 1)
            scope.showDevice = !scope.showDevice
            if scope.showDevice
              @commonService.publishEventBus "blast",{data:i}
              scope.defaultName = "爆炸3D"
            else
              @commonService.publishEventBus "3D",{data:i}
              scope.defaultName = "默认场景"
          if(scope.focus == 2)
            @commonService.publishEventBus "rotate",{data:i}
          if(scope.focus == 3)
            @commonService.publishEventBus "configuration",{data:i}
      showStation(scope)
#选择站点
      scope.selectStation = (station)=>
        scope.station = station
        showStation(scope)
#        选择设备
      scope.selectEquipment = (equip)=>
        console.log equip
        scope.equipment = equip
        publishEquipmentId(scope)


#    findParent: (scope, station) ->
#      parent = _.find scope.project.stations.items, (sta) ->sta.model.station is station.model.parent
#      if parent
#        scope.parents.push parent
#        @findParent scope, parent
    resize: (scope)->

    dispose: (scope)->


  exports =
    DevicePredictDirective: DevicePredictDirective