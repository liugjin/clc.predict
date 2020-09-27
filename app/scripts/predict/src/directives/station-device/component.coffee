###
* File: station-device-directive
* User: David
* Date: 2020/02/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationDeviceDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-device"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.mySwiper = new Swiper '.swiper-container', {slidesPerView: 'auto', spaceBetween: 15, freeMode: true, loop: false, observer: true, observeParents: true, normalizeSlideIndex: false, centeredSlides : false, preventDefault:true}
      @setData(scope)
      #      scope.stationEventBus?.dispose()
      #      scope.stationEventBus = @commonService.subscribeEventBus 'stationID',(msg)=>
      #        stationID = msg.message.data
      #        @commonService.loadStation stationID, (err,station) =>
      #          scope.station = station
      #          @setData(scope)
      scope.equipAlarmSubscribe = {}  # 关键设备订阅信息
      scope.inverterImg = @getComponentPath('images/inverter.svg')
      scope.motorImg = @getComponentPath('images/motor.svg')
      scope.switchboxImg = @getComponentPath('images/switch-box.svg')
      scope.transformerImg = @getComponentPath('images/transformer.svg')
      scope.typeImages = {}

    getColor2:(scope,item)=>
      item.severity= 0
      filter = scope.project.getIds()
      filter.station = scope.station?.model.station
      filter.equipment = item.model.equipment
      filter.signal = '_alarms'
      scope.equipAlarmSubscribe[item.key] = @commonService.signalLiveSession.subscribeValues filter, (err, d)=>
#        console.log 'd-----------',d
        if d.message.value > 0
          item.severityColor = '#f44336'

    getColor:(scope,item)=>
      signals = ["communication-status", "_alarms"]
      item.severity= 0
      filter = scope.project.getIds()
      filter.station = scope.station?.model.station
      filter.equipment = item.model.equipment
      for signal in signals
        filter.signal = signal
        @commonService.signalLiveSession.subscribeValues filter, (err, d)=>
          if not d?
            return
          else
            if d.message.severity > item.severity
              item.severity = d.message.severity
            if signal == "_alarms"
              item.severityColor=scope.project?.dictionary?.eventseverities?.getItem(item.severity)?.model.color if item.severity > 0

    setData: (scope)=>
      scope.station.loadEquipments null, null, (err, equipments)=>
        equipments.sort(@equipmentSort("index"))
        #scope.spliceArr =_.clone(equipments).splice(0,4)
        scope.spliceArr =_.filter _.clone(equipments),(item)=>
          return item.model.type isnt '_station_management'
        for item in scope.spliceArr
          @getColor2(scope, item)
          switch item.model.type
            when 'inverter'
              item.model.typeImg = scope.inverterImg
            when 'motor'
              item.model.typeImg = scope.motorImg
            when 'switch-box'
              item.model.typeImg = scope.switchboxImg
            when 'transformer'
              item.model.typeImg = scope.transformerImg
        setTimeout ()->
          $("#swiperBox").attr('style','visibility:visible')
        ,1000
      ,true
      #        console.log scope.spliceArr
      # 跳转页面
      scope.clickDevicn = (deviceData)=>
        window.location.hash = "#/device-details/#{scope.project.model.user}/#{scope.project.model.project}/#{scope.station.model.station}/#{deviceData.model.equipment}"
# 设备按照显示索引进行排序
    equipmentSort:(key)=>
      return (a,b)=>
        value1 = a.model[key]
        value2 = b.model[key]
        return value1 - value2

    getComponentPath: (path)->    # 基类的此方法有漏洞 这里重写
      scripts = document.getElementsByTagName("script")
      script = _.find scripts, (sp)=>sp.src.indexOf("/"+@id)>0 and sp.src.indexOf("/"+@id+"-")<0 and sp.src.indexOf("/component.js")>0
      script?.src+"/../"+path

    resize: (scope)->
      console.log scope.mySwiper
      for item in scope.mySwiper
         item.update()

    dispose: (scope)->
      _.mapObject scope.equipAlarmSubscribe,(item)=>
        item.dispose()

  exports =
    StationDeviceDirective: StationDeviceDirective
