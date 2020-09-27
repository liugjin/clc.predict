###
* File: device-configuration-directive
* User: David
* Date: 2020/02/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceConfigurationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-configuration"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.defaultName = "组合3D"
      scope.focus = 3
      scope.showDevice = false
      @getTemplates(scope)
      @clickTime(scope)
      #        全屏显示函数
      scope.fullscreen = (element) =>
        if not element
          return
        if typeof element is 'string'
          el = angular.element element
          element = el[0]
        exit = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement
        if exit
          if document.exitFullscreen
            document.exitFullscreen()
          else if document.webkitExitFullscreen
            document.webkitExitFullscreen Element.ALLOW_KEYBOARD_INPUT
          else if document.mozExitFullScreen
            document.mozExitFullScreen()
          else if document.msExitFullscreen
            document.msExitFullscreen()
        else
          if element.requestFullscreen
            element.requestFullscreen()
          else if element.webkitRequestFullscreen
            element.webkitRequestFullscreen Element.ALLOW_KEYBOARD_INPUT
          else if element.mozRequestFullScreen
            element.mozRequestFullScreen()
          else if element.msRequestFullscreen
            element.msRequestFullscreen()
      
      #订阅来自预测参数的信息 改变按钮文字
      scope.stationEventBusSelect?.dispose()
      scope.stationEventBusSelect = @commonService.subscribeEventBus 'select',(msg)=>
        if(msg and msg.message)
          scope.defaultName = "展开3D"
          scope.showDevice = true
      #订阅来自3D组件的告警展开信号 改变按钮文字
      scope.stationEventBusOpen?.dispose()
      scope.stationEventBusOpe = @commonService.subscribeEventBus 'alarm-open',(msg)=>
        if(msg and msg.message)
          scope.defaultName = "展开3D"
          scope.showDevice = true
      #
      # 跳转页面
      scope.clickStation = ()=>
        window.location.hash = "#/station-info/#{scope.project.model.user}/#{scope.project.model.project}/#{scope.station.model.station}"
      # 旋转3D
      scope.rotate=(i)=>
        @commonService.publishEventBus "rotate",{data:i}
    
    clickTime:(scope) =>
      clicktag = 0
      scope.clickTime=(i)=>
        # 发布主题
        if(scope.focus == 2)
          if clicktag == 0
            clicktag = 1
            setTimeout(()=>
              clicktag = 0
            ,1400) #定时器解决连续点击的问题
            scope.focus = i
            scope.showDevice = !scope.showDevice
            @commonService.publishEventBus "unfoldMerger",{data:scope.showDevice}
            if scope.showDevice
              scope.defaultName = "展开3D"
            else
              scope.defaultName = "组合3D"
          else
            console.log("请勿频繁点击")
        if(scope.focus == 3)
          scope.focus = i
          @commonService.publishEventBus "configuration",{data:i}

    # 获取设备模板，并设备筛选对应设备的组态ID 并通过模板ID选择对应的设备3D文件
    getTemplates:(scope)=>
      scope.project.loadEquipmentTemplates {template: ""}, '', (err, templates) =>
        for tem in templates
          if tem.model.template == scope.equipment.model.template
            scope.templateId = tem.model.graphic
            if tem.model.type == "motor" or tem.model.type == "inverter"
              scope.scene = @getComponentPath("./files/"+tem.model.type+".json")
            else
              scope.scene = ''
    resize: (scope)->

    dispose: (scope)->
      scope.stationEventBusSelect?.dispose()
      scope.stationEventBusOpen?.dispose()

  exports =
    DeviceConfigurationDirective: DeviceConfigurationDirective