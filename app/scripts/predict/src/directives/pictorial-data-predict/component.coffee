###
* File: pictorial-data-directive
* User: David
* Date: 2020/03/06
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "./swiper/swiper.min"], (base, css, view, _, moment, swiper) ->
  window.Swiper = swiper
  class PictorialDataPredictDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "pictorial-data"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.setting = setting
      scope.signals = {}
      scope.signalSubscriptions = {}
      setTimeout =>
        mySwiper = new Swiper '.swiper-container', {slidesPerView: 'auto', spaceBetween: 15, freeMode: true, loop: false, observer: true, observeParents: true, normalizeSlideIndex: false, centeredSlides : false}
      ,2000
      scope.devices = {}
      scope.defaultImg = @getComponentPath("images/device.svg")
      scope.station.loadEquipments {type: {$nin: ["_management", "_station_management"]}}, null, (err, equips) =>
        @filterEquipments scope, equips
        scope.selectedType = scope.types[0]

      scope.selectType = (type) ->
        scope.selectedType = type

      scope.imgError = (ele)->
        ele.src = scope.defaultImg if ele.src isnt scope.defaultImg
        ele.onerror = null

      scope.getColor = (severity, flag) ->
        if flag
          return scope.project?.dictionary?.eventseverities?.getItem(severity)?.model.color if severity > 0
        else
          return "black" if severity is -1
          return "#10EBF4" if severity is 0
          return scope.project?.dictionary?.eventseverities?.getItem(severity).model.color if severity > 0

      scope.selectDevice = (equipment) =>
        scope.selectDeviceName = equipment.model.name
        scope.device = equipment
        @publishEventBus "equipmentId", {stationId: equipment.model.station, equipmentId: equipment.model.equipment}
        console.log scope.signals
        $(".content2").hide()
        $("#equipment-template").show()
      scope.closeDeviceData = ()=>
        $(".content2").show()
        $("#equipment-template").hide()

    filterEquipments: (scope, equips) =>
      equips = _.filter(equips, (item)->item.model.type in scope.parameters.types)  if scope.parameters.types
      equips = _.filter(equips, (item)->item.model.template in scope.parameters.templates) if scope.parameters.templates
      for equip in equips
        equip.loadSignals()
        key = equip.model.station+"."+equip.model.equipment
        scope.signals[key] = {severity: {name:"设备状态", severity: -2, formatValue: "未知"}} if not scope.signals[key]

      scope.devices = _.groupBy equips, (item)->item.model.type
      scope.types = _.filter scope.project.dictionary.equipmenttypes.items, (item)->scope.devices[item.model.type]?
      scope.types = _.sortBy scope.types, (item)->0-item.model.index
      _.each scope.types, (type) =>
        @checkNameFile type.model.name, (response)->
          type.model.icon = type.model.name
        , (error)->
          type.model.icon = "device"

      setTimeout =>
        if scope.parameters.signals
          signals = scope.parameters.signals
        else
          signals = ["communication-status", "_alarms"]
        for signal in signals
          @subscribeSignal scope, signal
      , 2000

    checkNameFile: (name, success, error) ->
      @commonService.reportingService.$http.get(@getComponentPath("images/"+name+".svg")).then(success, error)

    subscribeSignal: (scope, signal) =>
      scope.signalSubscriptions[signal]?.dispose()
      filter = scope.project.getIds()
      filter.station = scope.station?.model.station
      filter.equipment = "+"
      filter.signal = signal
      scope.signalSubscriptions[signal] = @commonService.signalLiveSession.subscribeValues filter, (err, d)=>
        signal = scope.project.getSignalByTopic d.topic
        signal?.setValue d.message
        d.message.name = signal?.model.name
        d.message.formatValue = signal?.data.formatValue
        d.message.unitName = scope.project.typeModels.signaltypes.getItem(d.message.unit)?.model.unit
        key = d.message.station+"."+d.message.equipment
        scope.signals[key][d.message.signal] = d.message
        if d.message.severity > scope.signals[key].severity.severity
          scope.signals[key].severity.severity = d.message.severity
          scope.signals[key].severity.formatValue = switch d.message.severity
            when -1 then "通讯中断"
            when 0 then "运行正常"
            else
              scope.project.typeModels.eventseverities.getItem(d.message.severity)?.model.name

    resize: (scope)->

    dispose: (scope)->
      signal?.dispose() for key, signal of scope.signalSubscriptions

  exports =
    PictorialDataPredictDirective: PictorialDataPredictDirective