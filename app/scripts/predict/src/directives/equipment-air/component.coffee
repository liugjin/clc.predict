###
* File: equipment-air-directive
* User: David
* Date: 2019/12/04
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentAirDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-air"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      alert(123)
      scope.theAirStatu =
        equipName : ""
        equipStatu : ""
      scope.equipments = []
      scope.colorChange = false
      #获取项目站点(若有多个站点)
      scope.stations = _.each scope.project.stations.nitems,(n)-> n.model.station
      _.each scope.stations,(station)=>
        station?.loadEquipments {type: "aircondition"}, null, (err, equips)=>
          scope.equipments = equips
          #如果有多个站点
          #          _.map equips,(eqeq)=>
          #            scope.equipments.push(eqeq)
          scope.selectEquipment = (equip) =>
            scope.subscribeStation?.dispose()
            scope.subscribeStation = @commonService.subscribeEquipmentSignalValues equip, (signal) =>
              if signal.model.signal == "communication-status"
                if signal.data
                  scope.theAirStatu.equipStatu = signal.data.formatValue
                  scope.theAirStatu.equipName = signal.equipment.model.name
                  if signal.data.value == 0
                    scope.colorChange = false
                  else
                    scope.colorChange = true
              else
                scope.theAirStatu.equipStatu = "--"
                scope.theAirStatu.equipName = "--"
                scope.colorChange = true
        , true




    resize: (scope)->

    dispose: (scope)->
      scope.subscribeStation?.dispose()


  exports =
    EquipmentAirDirective: EquipmentAirDirective