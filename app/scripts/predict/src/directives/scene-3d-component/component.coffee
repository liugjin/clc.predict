###
* File: room-3d-component-directive
* User: David
* Date: 2019/02/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'lodash', "moment","./room"], (base, css, view, _, moment,Room) ->
  class Scene3dComponentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "scene-3d-component"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      console.log("设备",scope.equipment)
      console.log("站点",scope.station)
      scope.showDevice = false
      scope.equipSubscription = {}
      room = new Room(
        "room-1",
        element.find('.room-3d-canvas')[0],
        {
          camera:{
            type:scope.parameters.camera?.type||"PerspectiveCamera",
            fov:scope.parameters.camera?.fov||50,
            x:scope.parameters.camera?.x||0,
            y:scope.parameters.camera?.y||0,
            z:scope.parameters.camera?.z||0,
            rotationX:scope.parameters.camera?.rotationX||0,
            rotationY:scope.parameters.camera?.rotationY||0,
            rotationZ:scope.parameters.camera?.rotationZ||0
          },
          renderder:{alpha:true,antialias:true},
          orbitControl:true
        }
      )
      scope.room = room

      scope.updateIconsStyle=(reflesh)=>
        if scope.updateIconsFlag or reflesh
          if scope.iconThings?.length>0
            for thing in scope.iconThings
              coordinate = room.getScreenCoordinate(thing.showingObject)
              thing.iconStyle={}
              thing.iconStyle["width"] = scope.iconSize+'px'
              thing.iconStyle["height"] = scope.iconSize+'px'
              left = Number( (coordinate.x-room.offsetLeft-scope.iconSize/2).toFixed(0))
              top = (coordinate.y-room.offsetTop-scope.iconSize/2).toFixed(0)
              thing.iconStyle["left"] = left+'px'
              thing.iconStyle["top"] = top+'px'
          if scope.dataBoxThings?.length>0
# 更新 data-box 样式
            for thing in scope.dataBoxThings
              coordinate = room.getScreenCoordinate(thing.showingObject)
              thing.dataBoxStyle={}
              left = Number( (coordinate.x-room.offsetLeft).toFixed(0))
              top = (coordinate.y-room.offsetTop).toFixed(0)
              thing.dataBoxStyle["left"] = left+'px'
              thing.dataBoxStyle["top"] = top+'px'

      scope.$watch 'parameters.scene',(scene)=>
        return if not scene
        preloadCallback=(preloadValue)=>
          scope.preloadValue = preloadValue
        scope.sceneLoadedCompleted = false
        @rotateRoom(scope,false)
        room.loadScene(scene,()=>
          scope.sceneLoadedCompleted = true
          console.log("3D文件加载完了订阅信号")
          @subscribeSignal(scope)
          @getDeviceSignal(scope,scope.equipment,'alarm-status')
        ,preloadCallback,{noCache:scope.parameters?.options?.noCache})
      scope.$watch 'parameters.stationId',(stationId)->
        return if not stationId
        console.log(stationId)


# 订阅按钮信号
    subscribeSignal:(scope)=>
# 订阅旋转按钮信号
      @commonService.subscribeEventBus 'rotate',(msg)=>
        if(msg and msg.message)
          console.log("订阅信号",msg)
          @rotateRoom(scope,!scope.flag)
      # 订阅显示设备按钮信号
      @commonService.subscribeEventBus 'showDevice',(msg)=>
        if(msg and msg.message)
          console.log("订阅信号",msg)
          @changeMaterial(scope,!scope.showDevice)
      # 订阅默认场景按钮信号
      @commonService.subscribeEventBus 'default',(msg)=>
        if(msg and msg.message)
          console.log("订阅信号",msg)
          @changeMaterial(scope,false)
# 旋转事件
    rotateRoom:(scope,flag)=>
      scope.flag = flag
      scope.room.autoRotate(flag,1)
      if flag
        scope.room.addAnimate('rotateRoom',()=>
          scope.updateIconsStyle(true)
        )
      else
        scope.room.removeAnimate('rotateRoom')

    changeMaterial:(scope,flag)=>
      scope.showDevice = flag
      scope.room.changeMaterial(flag)

# 获取设备信号
    getDeviceSignal:(scope,equipments,signalID)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
        equipment: '+'
        signal: signalID
      str = scope.station.key + "-"+ signalID
      scope.equipSubscription[str]?.dispose()
      scope.equipSubscription[str] = @commonService.signalLiveSession.subscribeValues filter,(err, d)=>
        console.log("信号",d)
        if d and d.message
          scope.room.generatorThings(d.message.equipment,d.message.value)
    resize: (scope)->

    dispose: (scope)->
      scope.room?.dispose()
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()



  exports =
    Scene3dComponentDirective: Scene3dComponentDirective