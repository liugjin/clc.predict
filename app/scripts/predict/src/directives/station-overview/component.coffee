###
* File: station-overview-directive
* User: David
* Date: 2019/12/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationOverviewDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-overview"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 获取所有站点
      scope.project.loadStations null, (err, stations)=>
        scope.stations = _.filter stations,(station)->station.model.parent
        @ergodicSite(scope)
#        console.log("stations",scope.stations)
      # 跳转页面
      scope.clickStation = (station)=>
        window.location.hash = "#/station-info/#{scope.project.model.user}/#{scope.project.model.project}/#{station.model.station}"
      # 对站点进行遍历
    ergodicSite:(scope)=>
      for site in scope.stations
        site.model.allDeviceNumber = '00'
        @getDevices(scope,site)
# 获取设备总数
    getDevices: (scope,site) =>
      site.loadEquipments null, null, (err, equipments)=>
        equipments = _.filter equipments,(equip)->equip.model.equipment.charAt(0) isnt '_'
        site.model.allDeviceNumber = @addZero(equipments.length)
    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num

    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()


  exports =
    StationOverviewDirective: StationOverviewDirective