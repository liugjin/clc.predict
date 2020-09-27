###
* File: device-3d-component-directive
* User: David
* Date: 2020/02/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","./room","tween"], (base, css, view, _, moment,Room,TWEEN) ->
  class Device3dComponentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-3d-component"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.equipmentType = scope.equipment.model.type
      scope.equipSubscription = {}
      scope.eventSubscriptionArray = []
      scope.events = {}
      scope.scene = ''
      scope.times = ""
      scope.subValueFlag = 1
      scope.open = false #默认为合并，当调用room 合并展开函数会改变该值
      scope.label = { top: 960,left: 617, display: "none"}
      scope.preloadValue = 0
      room = new Room(scope,$(element.find(".room-3d-canvas")[0]))
      scope.room = room
      scope.$watch 'parameters.scene',(scene)=>
        scope.scene = scene
        return if not scene
        loadSignalProperties()
        @sceneRoute(scope)
       # 实时时间
      scope.day = moment().format('YYYY-MM-DD')
      scope.time = moment().format('HH:mm:ss')
      scope.date = moment().format('dddd')
      clearInterval scope.interval
      scope.interval = setInterval(()=>
        scope.day = moment().format('YYYY-MM-DD')
        scope.time = moment().format('HH:mm:ss')
        scope.date = moment().format('dddd')
        scope.$applyAsync()
        scope.times = "#{scope.day} #{scope.time}"
      ,1000)
      scope.boxNone = ()=>
        scope.label.display = "none"

#   获取设备故障信号的属性
      loadSignalProperties = ()=>
        scope.equipment?.loadProperties null, (err, properties) =>
          scope.knowledge_base = JSON.parse(scope.equipment.propertyValues?._knowledge_base || '{}')
          console.log scope.knowledge_base
    #接受3D路径
    sceneRoute:(scope)=>
      scope.sceneLoadedCompleted = false
      preloadCallback=(preloadValue)=>
        scope.preloadValue = preloadValue
      scope.room.loadSceneByUrl(scope.scene,()=>
        scope.sceneLoadedCompleted = true
        # 加载完3D才订阅信号
        @subscribeSignal(scope)
        @getDeviceSignal(scope)
      ,preloadCallback)

    # 订阅按钮信号
    subscribeSignal:(scope)=>
      console.log("函数执行")
      # 订阅旋转按钮信号
      scope.stationEventBusRotate?.dispose()
      scope.stationEventBusRotate = @commonService.subscribeEventBus 'rotate',(msg)=>
        if(msg and msg.message)
          scope.flag = !scope.flag
          scope.room.autoRotate(scope.flag,1) #启用和关闭旋转,旋转的速度
      # 订阅还原爆炸按钮信号
      scope.stationEventBusBlast?.dispose()
      scope.stationEventBusBlast = @commonService.subscribeEventBus 'unfoldMerger',(msg)=>
        if(msg and msg.message)
          if(msg.message.data)
            scope.room.unpackAction()
          else
            scope.room.packAction()
      #订阅来自预测参数的信息
      scope.stationEventBusSelect?.dispose()
      scope.stationEventBusSelect = @commonService.subscribeEventBus 'select',(msg)=>
        if(msg and msg.message)
          if(!scope.open) #判断当前是否为展开
            scope.room.unpackAction()
          scope.room.selection(msg.message.data)

    # 旋转事件
    rotateRoom:(scope,flag)=>
      scope.flag = flag
      scope.room.autoRotate(flag,10) #启用和关闭旋转,旋转的速度

    # 获取该设备的所有信号点
    getDeviceSignal:(scope)=>
      # 获取该设备的所有信号点
      scope.equipment.loadSignals null,(err,signals)=>
        if(signals)
          for sig in signals
            if(sig.model.type == scope.equipment.model.type)
              if(sig.model.template == "base-"+scope.equipment.model.type and sig.model.signal !="device-flag")
                @getDeviceSpecialSignal(scope,scope.equipment,sig)

    #封装获取设备信息号函数
    getDeviceSpecialSignal:(scope,equipment,sig)=>
      signalID = sig.model.signal
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: equipment.model.station
        equipment: equipment.model.equipment
        signal: signalID
      str = equipment.key + "-"+ signalID

      console.log '2222222222222'
      currentSig = {
        message:
          signal: sig.model.signal
          signalName: sig.model.name
          signalState: '-'
          signalValue: 0
          advice: '暂无'
          atime: '-'
      }
      scope.room.generatorThings(currentSig,scope.open,null)
      scope.equipSubscription[str]?.dispose()
      scope.equipSubscription[str] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
        console.log '1111111111111111111'
        if signal and signal.message
          if sig.model.signal == signal.message.signal
            currentAdvice = scope.knowledge_base[sig.model.signal]
            console.log("currentAdvice",currentAdvice)
            signal.message.signalName = sig.model.name
            signal.message.signalID = signal.message.signal
            signal.message.atime = moment(signal.message.timestamp).format("YYYY-MM-DD HH:mm:ss")
            if(signal.message.value< 25)
              signal.message.signalState = "优秀"
              signal.message.advice = currentAdvice.level1
              scope.room.generatorThings(signal,scope.open,null)
            if(signal.message.value>=25 and signal.message.value< 50)
              signal.message.signalState = "良好"
              signal.message.advice = currentAdvice.level2
              scope.room.generatorThings(signal,scope.open,"#0094ff")
            if(signal.message.value>=50 and signal.message.value< 75)
              signal.message.signalState = "一般"
              signal.message.advice = currentAdvice.level3
              scope.room.generatorThings(signal,scope.open,"#F4D601")
            if(signal.message.value>=75)
              signal.message.signalState = "极差"
              signal.message.advice = currentAdvice.level4
              if(!scope.open) #判断当前是否为展开
                scope.room.unpackAction()
                @commonService.publishEventBus "alarm-open",{data:"open"}
              scope.room.generatorThings(signal,scope.open,"#ff0045")



    resize: (scope)=>
      # @sceneRoute(scope)
      scope.room.resize()
    dispose: (scope)->
      scope.stationEventBusRotate?.dispose()
      scope.stationEventBusBlast?.dispose()
      scope.stationEventBusSelect?.dispose()
      clearInterval scope.interval
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    Device3dComponentDirective: Device3dComponentDirective