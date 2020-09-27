###
* File: device-monitor-directive
* User: David
* Date: 2019/07/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceMonitorDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-monitor"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      element.css("display", "block")

      publishEquipmentId = (scope) =>
        scope.stationAndEquip = {
          stationId: scope.equipment?.model?.station
          equipmentId: scope.equipment?.model?.equipment
        }
        @commonService.publishEventBus "equipmentId", scope.stationAndEquip

      showStation = (scope) =>
        scope.parents = []
        filter = if scope.parameters.type then {type: scope.parameters.type} else null
        scope.station.loadEquipments filter, null, (err, equips)=>
          return if  err
          filtersEquipment = _.filter equips,(equip)-> equip.model.equipment isnt '_station_management'
          scope.equipments = filtersEquipment
          if not scope.equipment or scope.equipment.model.station isnt scope.station.model.station
            scope.equipment = filtersEquipment?[0]
            publishEquipmentId(scope)
          else
            publishEquipmentId(scope)

        @findParent scope, scope.station
        scope.stations = scope.parents[0]?.stations
        scope.parents = scope.parents.reverse()

      showStation(scope)

      scope.selectStation = (station)=>
        scope.station = station
        showStation(scope)

      scope.selectEquipment = (equip)=>
        scope.equipment = equip
        publishEquipmentId(scope)

    findParent: (scope, station) ->
      parent = _.find scope.project.stations.items, (sta) ->sta.model.station is station.model.parent
      if parent
        scope.parents.push parent
        @findParent scope, parent

    resize: (scope)->

    dispose: (scope)->


  exports =
    DeviceMonitorDirective: DeviceMonitorDirective