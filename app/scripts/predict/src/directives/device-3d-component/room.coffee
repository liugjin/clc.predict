
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`
define ["underscore","threejs","tween"], (_,THREE,TWEEN) ->
  showingType = ["normal","wireframe","capacity"]
  if(!window.debugR)
    window.debugR={}
  class Room
    constructor: (scope,element) ->
      @init()
      @dom = element
      @scope = scope
      @oldPositionArr = []
      @animateList = []
      @currentHex = null
      @offset = { left: 0, top: 0, width: 0, height: 0 }
      @meshClick()
    # 初始化
    init: () => (
      @animate = null
      @scene = new THREE.Scene()
      @scene.autoUpdate = true
      @camera = new THREE.PerspectiveCamera( 40, window.innerWidth / window.innerHeight, 1, 1000 )
      @renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
      @renderer.setPixelRatio( window.devicePixelRatio )
      @renderer.setSize( window.innerWidth, window.innerHeight )
      @renderer.shadowMap.enabled = true
      # @renderer.gammaOutput = true
      @renderer.gammaFactor = 2.2
      @renderer.setClearColor(0xEEEEEE, 0.0)
      @controls = new THREE.OrbitControls(@camera,@renderer.domElement)
      @controls.target.set( 0, 0, 0 )
      @controls.enablePan = false
      @controls.maxPolarAngle = Math.PI / 2
      @raycaster = new THREE.Raycaster()
      @mouse = new THREE.Vector2()
      @clock = new THREE.Clock()
    )

    # 设置场景
    setScene:(options) =>
      width = @dom.width()
      height = @dom.height()
      # 更新摄像机
      @camera.position.set options.x or 0, options.y or 0, options.z or 0
      @camera.rotation.set options.rotationX * Math.PI / 180 or 0, options.rotationY * Math.PI / 180 or 0, options.rotationz * Math.PI / 180 or 0
      @camera.fov = options.fov
      @camera.aspect = width / height
      # 设置渲染器
      @renderer.setSize(width, height)
      @dom.append(@renderer.domElement) if @dom.children().length == 0
      # 设置关键帧
      @composer = @setComposer({ width, height, color: ['rgba(0,214,255,0.3)'] })
      # 设置边界距
      @offset = { width, height, left: @dom.offset().left, top: @dom.offset().top }
      # 开始渲染
      cancelAnimationFrame(@animate) if _.isNull(@animate)
      @render()
    # 更新scene
    loadSceneByUrl: (url, callback, preloadCallback)=>
      @objLoader = new THREE.ObjectLoader() if !@objLoader
      onLoad = (json) =>
        @scene.remove(@scene.children)
        @scene.add(json)
        @setScene(json.userData)
        callback?(null,json)
      onProgress = (xhr) =>
        preloadCallback?((xhr.loaded / xhr.total * 100).toFixed(0))
      onErrors = (xhr) ->
        console.error '加载3D文件失败：',xhr
      @objLoader.load url, onLoad, onProgress , onErrors

     # 渲染
    render: () =>
      @animate = requestAnimationFrame(@render)
      @composer.render()
      @controls.update() #重置轨道控制器

    # 点击mesh
    meshClick:()=>
      @dom.click((event) =>
        @autoRotate(false,1)
        offset = @offset
        return if offset.height == 0 or offset.width == 0
        @mouse.x = (event.originalEvent.clientX - offset.left) / offset.width * 2 - 1
        @mouse.y = -((event.originalEvent.clientY - offset.top) / offset.height) * 2 + 1
        @raycaster.setFromCamera( @mouse, @camera );
        intersects = @raycaster.intersectObjects(@scene.children[0].children,true)
        if intersects.length > 0 && intersects[0].object.name.indexOf("signal") != -1
          # if intersects[0].object.signal
          if intersects[0].object.material.emissive #兼容FBx格式的模型
            @outlinePass.visibleEdgeColor = intersects[0].object.material.emissive
            @outlinePass.hiddenEdgeColor = intersects[0].object.material.emissive
          else if intersects[0].object.material.color
            @outlinePass.visibleEdgeColor = intersects[0].object.material.color
            @outlinePass.hiddenEdgeColor = intersects[0].object.material.color
          # else
          #   @outlinePass.visibleEdgeColor.set("rgba(0,214,255,0.3)");
          #   @outlinePass.hiddenEdgeColor.set("rgba(0,214,255,0.3)");
          @outlinePass.selectedObjects = [intersects[0].object]
          @scope.label = @getScreenCoordinate(@outlinePass.selectedObjects[0], {
            width: @offset.width, height: @offset.height, top: @offset.top, left: @offset.left
          })
          @scope.$applyAsync()
        else
          console.log '不显示'
          @outlinePass.selectedObjects = []
          @scope.label.display = "none"
      )
    
    # 接受主要预测参数信号后选中mesh
    selection:(data)=>
      @scene.traverse((object3D)=>
        if(object3D.name.indexOf("signal-"+data.signalID) != -1 and object3D.type == 'Mesh')
          if object3D.material.emissive #兼容FBx格式的模型
            @outlinePass.visibleEdgeColor = object3D.material.emissive
            @outlinePass.hiddenEdgeColor = object3D.material.emissive
          else if object3D.material.color
            @outlinePass.visibleEdgeColor = object3D.material.color
            @outlinePass.hiddenEdgeColor = object3D.material.color
          @outlinePass.selectedObjects = [object3D]
          @scope.label = @getScreenCoordinate(@outlinePass.selectedObjects[0], {
            width: @offset.width, height: @offset.height, top: @offset.top, left: @offset.left
          })
      )


    # 通过mesh对象获取屏幕坐标
    getScreenCoordinate: (mesh, data) =>
      position = new THREE.Vector3()
      mesh.localToWorld(position)
      vec2 = position.project(@camera)
      widthHalf = data.width / 2
      heightHalf = data.height / 2
#      top: Math.round((1 - vec2.y) * heightHalf + data.top)
      console.log mesh.signal
      return {
        left: Math.round((1 + vec2.x) * widthHalf),
        top: Math.round((1 - vec2.y) * heightHalf),
#        left: "30px"
#        top: "160px"
        display: "block"
        signal: mesh.signal
        meshName: mesh.name 
      }

  


    # 设置渲染效果帧  
    setComposer: (data) =>
      @renderer.setRenderTarget(new THREE.WebGLRenderTarget(data.width, data.height, { 
        minFilter: THREE.LinearFilter, 
        magFilter: THREE.LinearFilter, 
        format: THREE.RGBAFormat, 
        stencilBuffer: false
      }))
      
      composer = new THREE.EffectComposer( @renderer )
      
      renderPass = new THREE.RenderPass( @scene, @camera );
      composer.addPass( renderPass );

      @outlinePass = new THREE.OutlinePass( new THREE.Vector2( data.width, data.height ), @scene, @camera );
      @outlinePass.edgeStrength = 10
      @outlinePass.edgeGlow = 1
      @outlinePass.edgeThickness = 1
      @outlinePass.pulsePeriod = 3
      @outlinePass.visibleEdgeColor.set(data.color[0]);
      @outlinePass.hiddenEdgeColor.set(data.color[0]);
      @outlinePass.selectedObjects = []

      composer.addPass( @outlinePass );

      effectFXAA = new THREE.ShaderPass( THREE.FXAAShader );
      effectFXAA.uniforms[ 'resolution' ].value.set( 1 / data.width, 1 / data.height );
      effectFXAA.renderToScreen = true
      effectFXAA.clear = true
      composer.addPass( effectFXAA );
      return composer

    # 围绕目标旋转
    autoRotate:(flag,autoRotateSpeed)->
      @controls?.autoRotateSpeed = autoRotateSpeed || 2 #围绕目标旋转的速度
      if flag
        @controls?.autoRotate = true #可自动围绕目标旋转 必须 在动画循环中调用.update（）
        @addAnimate('autoRotate',()=>
          @controls?.update()
        )
      else
        @controls?.autoRotate = false
        @removeAnimate('autoRotate')

    # 遍历3d模型
    generatorThings:(data,open,color)->
      @scene.traverse((object3D)=>
        if(object3D.name.indexOf("signal-"+data.message.signal) != -1 and object3D.type == 'Mesh')
          object3D.signal = {signalName:data.message.signalName,time:data.message.atime,signalState:data.message.signalState,signalValue:data.message.value,advice:data.message.advice}
          if object3D.material.emissive #兼容FBx格式的模型
            if @currentHex == null
              @currentHex = object3D.material.emissive.getHex()
            if color == null
              object3D.material.emissive.set(@currentHex)
            else
              object3D.material.emissive.set(color)
          else if object3D.material.color
            if @currentHex == null
              @currentHex = object3D.material.color.getHex()
            if color == null
              object3D.material.color.set(@currentHex)
            else
              object3D.material.color.set(color)
          if(open) #当有告警就弹窗弹窗
            @selection(data.message)
      )

    # 添加动画
    addAnimate:(key,func)->
      index = _.findLastIndex(@animateList, {key: key})
      if index is -1
        @animateList.push({key:key,func:func})
      else
        @animateList[index]?.func = func
    # 删除动画
    removeAnimate:(key)->
      index = _.findLastIndex(@animateList, {key: key})
      return console.log('err: key is not in list',key,@animateList) if index is -1
      @animateList.splice(index,1)

    # 爆炸
    unpackAction:()=>
      @scope.open = true
      @scene.traverse((value)=>
        # if value.isMesh or value.isGroup 
        if value.userData.selectedPositionOffset 
          originalX = value.position.x
          originalY = value.position.y
          originalZ = value.position.z
          setupX = value.userData.selectedPositionOffset.x
          setupY = value.userData.selectedPositionOffset.y
          setupZ = value.userData.selectedPositionOffset.z
          value.originalPosition = new THREE.Vector3(originalX,originalY,originalZ) #原始坐标
          value.setupPosition = new THREE.Vector3(setupX,setupY,setupZ) #改变后的坐标
          tween = new TWEEN.Tween(value.position)
          tween.to({
            x: value.setupPosition.x
            y: value.setupPosition.y
            z: value.setupPosition.z
          },2000).easing(TWEEN.Easing.Elastic.Out)#动画方式
          tween.start()
      )
      animate = (time) =>
        requestAnimationFrame(animate)
        TWEEN.update(time)
      requestAnimationFrame(animate)
      
    # 合并
    packAction:()=>
      @scope.open = false
      @scene.traverse((value)=>
        if value.originalPosition
          tween = new TWEEN.Tween(value.position)
          tween.to({
            x: value.originalPosition.x
            y: value.originalPosition.y
            z: value.originalPosition.z
          },2000).easing(TWEEN.Easing.Exponential.Out)#动画方式
          tween.start()
      )
      animate = (time) =>
        requestAnimationFrame(animate)
        TWEEN.update(time)
      requestAnimationFrame(animate)
      
    # 自适应
    resize: () =>
      console.log("自适应")
      width = @dom.width()
      height = @dom.height()
      if width !=  @offset.width or height !=  @offset.height
        @camera.aspect = width / height
        @camera.updateProjectionMatrix()
        @renderer.setSize(width, height)
        @offset = { width, height, left: @dom.offset().left, top: @dom.offset().top }
        @scope.$applyAsync()
    dispose: ()->

      
  exports = Room