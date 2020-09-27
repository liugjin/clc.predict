###
* File: 3d/room
* User: Hardy
* Date: 2018/08/22
* Desc:
###
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`
define ["underscore","threejs","orbit-controls"], (_,THREE) ->
  class Room
    constructor:(name,element,options)->
      console.log("name",name)
      @name = name
      @options = options
      @element = element
      @isDisposed = false
      @currentHex = null
      @animateList = []
      @innerWidth = element.clientWidth #窗口宽度
      @innerHeight = element.clientHeight #窗口高度
      @scene = new THREE.Scene()#创建场景对象Scene
      #创建渲染器对象
      @renderer = new THREE.WebGLRenderer(options.renderder)
      @renderer.setSize @innerWidth, @innerHeight
      @renderer.setClearColor 0x000000, 0
      element.appendChild @renderer.domElement
      cameraOptions = options.camera
      cameraOptions.aspect = @innerWidth / @innerHeight #窗口宽高比
      return console.error("请检查样式，保证canvas有占用实际空间，否则无法渲染。") if not cameraOptions.aspect
      @initCamera cameraOptions #初始化照相机
      #添加事件侦听器
      element.addEventListener "click",@onMouseDblclick.bind(@) #单击
      #轨道控制）控制模型交互动作
      if options.orbitControl
        @orbitControl = new THREE.OrbitControls(@camera,@renderer.domElement) #声明轨道控制器插件
      @animate()
      @initDb()

    #初始化相机
    initCamera:(options)->
      switch options.type
        when 'PerspectiveCamera'
          if( !options.aspect )
            return console.error("透视相机应该有相位参数.")
          else
            @camera = new (THREE.PerspectiveCamera)(options.fov, options.aspect, 0.1, 100000)
          break
        else
          console.error '初始化摄像头错误: 不支持 ', options.type
          break
      @camera.position.set options.x or 0, options.y or 0, options.z or 0 #设置相机位置
      @camera.rotation.set options.rotationX * Math.PI / 180 or 0, options.rotationY * Math.PI / 180 or 0, options.rotationz * Math.PI / 180 or 0

    #初始化场景
    initScene:(obj)->
      @scene = obj
      if @scene.userData
        @setCamera @scene.userData
      # 清除场景背景以保持透明
      @scene.background = null
      @renderer.render @scene, @camera #执行渲染操作


    #设置相机
    setCamera:(options)->
      return console.log("setcamera选项为空") if not options
      if options.fov
        @camera.fov = options.fov
      @camera.position.set options.x or 0, options.y or 0, options.z or 0 #设置相机位置
      @camera.rotation.set options.rotationX * Math.PI / 180 or 0, options.rotationY * Math.PI / 180 or 0, options.rotationz * Math.PI / 180 or 0
      @camera.updateProjectionMatrix()
      if @orbitControl
        @orbitControl.update()

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

    #监听鼠标的变化，改变相机对象的属性，使3D模型能放到缩小和旋转
    animate:()->
      @animateList.forEach((obj)->
        if(_.isFunction(obj.func))
          obj.func()
      )
      if @composer
        @composer.render()
      else
        @renderer.render @scene, @camera

      if !@isDisposed
        animateFun = @animate.bind(@)
        requestAnimationFrame(animateFun)

    
    loadScene:(url,callback,preloadCallback,options)->
      if options?.noCache
        return @loadSceneByUrl(url,callback,preloadCallback)#如果无缓存获取场景文件的url
      load=()=>
        @getDataFromDatabase url,(err,json)=> 
          return console.warn(err) if err
          if json
            @loadSceneByJSON(json,callback)
          else
            @loadSceneByUrl(url,callback,preloadCallback,true)
      if !@db
        @dbCallback=(err)=>
          return console.warn(err) if err
          load()
      else
        load()
  
    loadSceneByUrl:(url,callback,preloadCallback,cache)->
      loader = new THREE.ObjectLoader
      onLoad = (obj) =>
        if cache
          @setDataToDataBase(url,obj)
        @initScene(obj)
        callback?(null,obj)
      onProgress = (xhr) ->
        preloadCallback?((xhr.loaded / xhr.total * 100).toFixed(0))
      onErrors = (xhr) ->
        console.error '加载3D文件失败：',xhr
      loader.load url, onLoad, onProgress , onErrors


    loadSceneByJSON:(json,callback)->
      loader = new THREE.ObjectLoader
      object =JSON.parse(json)
      loader.parse object,(obj)=>
        @initScene(obj)
        callback?(null,obj)

    # 旋转动画
    autoRotate:(flag,autoRotateSpeed)->
      @orbitControl?.autoRotateSpeed = autoRotateSpeed || 2
      if flag
        @orbitControl?.autoRotate = true
        @addAnimate('autoRotate',()=>
          @orbitControl?.update()
        )
      else
        @orbitControl?.autoRotate = false
        @removeAnimate('autoRotate')



    # 鼠标单击触发的方法
    onMouseDblclick:(event)=>
    #   #获取 raycaster 和所有模型相交的数组，其中的元素按照距离排序，越近的越靠前
    #   intersects = @getIntersects(event)
    #   #获取选中最近的 Mesh 对象
    #   if intersects.length != 0 and intersects[0].object instanceof THREE.Mesh and intersects[0].object.name.indexOf("$") == 0
    #     selectObject = intersects[0].object
    #     @changeMaterial(selectObject)
    #   else
    #     console.log('未选中 Mesh!')
    # # 获取与射线相交的对象数组
    # getIntersects:(event)=>
    #   event.preventDefault()
    #   console.log("event.clientX:"+event.clientX)
    #   console.log("event.clientY:"+event.clientY)
    #   checkList = []
    #   for children in @scene.children
    #     if(children.name.indexOf("$") == 0)
    #       checkList.push children
    #   #声明 raycaster 和 mouse 变量
    #   raycaster = new THREE.Raycaster()
    #   mouse = new THREE.Vector2()
    #   #通过鼠标点击位置,计算出 raycaster 所需点的位置,以组件为中心点,范围 -1 到 1
    #   mouse.x = (event.clientX / @innerWidth) * 2 - 1
    #   mouse.y = -(event.clientY / @innerHeight) * 2 + 1
    #   #通过鼠标点击的位置(二维坐标)和当前相机的矩阵计算出射线位置
    #   raycaster.setFromCamera(mouse, @camera)
    #   #获取与raycaster射线相交的数组集合，其中的元素按照距离排序，越近的越靠前
    #   intersects = raycaster.intersectObjects(checkList,true)
    #   return intersects

    #改变对象材质属性
    changeMaterial:(object)=>
      console.log("材质",object)
      @scene.traverse((object3D)=>
        if(object3D.name.indexOf("$") == 0)
          if object3D.type == 'Mesh'
            if object
              object3D.material.wireframe = true
            else 
              object3D.material.wireframe = false
      )
      # if @iswireframe
      #   object.material.wireframe = true
      #   @iswireframe = false
      # else 
      #   object.material.wireframe = false
      #   @iswireframe = true
    # 遍历3d模型
    generatorThings:(equipment,value)->
      @scene.traverse((object3D)=>
        if(object3D.name.indexOf(equipment) == 0)
          if object3D.type == 'Group'
            if object3D.children.length > 0
              for children in object3D.children
                if children.type == 'Mesh'
                  if @currentHex == null
                    @currentHex = children.material.color.getHex()
                  if value == 1
                    children.material.color.set(0xff0045)
                  if value !=1
                    children.material.color.set(@currentHex)
      )

    # 调用流览器数据库
    initDb:()->
      if not @db
        request = indexedDB.open("3d-files-db")
        request.onerror=(event)=>
          console.log("Database error: "+event.target.errorCode)
          @dbCallback?("Database error: "+event.target.errorCode)
        request.onupgradeneeded=(event)=>
          @db = event.target.result
          if not @db.objectStoreNames.contains('3d-files-table')
            @db.createObjectStore('3d-files-table', { keyPath: 'id' })
        request.onsuccess=(event)=>
          @db = event.target.result
          @dbCallback?()
      else
        @dbCallback?()

   
    getDataFromDatabase:(path,cb)->
      return console.warn("db is null") if not @db
      transaction = @db.transaction(["3d-files-table"],"readonly")
      objectStore = transaction.objectStore('3d-files-table')
      objectStoreRequest=objectStore.get(path)
      transaction.onerror =(event)=>
        console.warn("transaction error:",event)

      objectStoreRequest.onsuccess=()=>
        cb?(null,objectStoreRequest.result?.data)

      objectStoreRequest.onerror=(event)=>
        cb?(event)

    setDataToDataBase:(key,data)->
      return console.warn("db is null") if not @db
      transaction = @db.transaction(["3d-files-table"],"readwrite")
      transaction.onerror =(event)=>
        console.warn("transaction error:",event)

      objectStore = transaction.objectStore('3d-files-table')
      objectStore.put({id:key,data:JSON.stringify(data)})

  
    dispose:()->
      @isDisposed = true
      @animateList = []
      @renderer.dispose()



  exports = Room