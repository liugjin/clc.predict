###
* File: inventory-manage-directive
* User: bingo
* Date: 2018/11/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class InventoryManageDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "inventory-manage"
      super $timeout, $window, $compile, $routeParams, commonService
      @allInventoryStations = []

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      element.css("display", "block")
      #console.log($scope.project)
      $scope.setting = setting
      $scope.currentType = null
      $scope.equipTypes = null
      $scope.view = true
      $scope.detail = false
      $scope.editShow = false
      $scope.assetShow = false
      $scope.addShow = true
      $scope.add = false
      $scope.viewName = '列表'
      $scope.pageIndex = 1
      $scope.pageItems = 12
      preview = element.find('.img-preview')
      input = element.find('input[type="file"].img-input')
      $scope.dir = setting.urls.uploadUrl
      $scope.accept = "image/*"
      $scope.showLink = false
      $scope.addImg = @getComponentPath('image/add.svg')
      $scope.viewImg = @getComponentPath('image/view.svg')
      $scope.backImg = @getComponentPath('image/back.svg')
      $scope.detailBlueImg = @getComponentPath('image/detail-blue.svg')
      $scope.editBlueImg = @getComponentPath('image/edit-blue.svg')
      $scope.saveImg = @getComponentPath('image/save-blue.svg')
      $scope.detailGreenImg = @getComponentPath('image/detail-green.svg')
      $scope.editGreenImg = @getComponentPath('image/edit-green.svg')
      $scope.deleteGreenImg = @getComponentPath('image/delete-green.svg')
      $scope.copyGreenImg = @getComponentPath('image/copy-green.svg')
      $scope.uploadImg = @getComponentPath('image/upload.svg')
      $scope.deleteImg = @getComponentPath('image/delete.svg')
      $scope.linkImg = @getComponentPath('image/link.svg')
      $scope.downImg = @getComponentPath('image/download.svg')
      $scope.noEquipImg = @getComponentPath('image/no-equip.svg')
      $scope.project.loadEquipmentTemplates {}, null

      # 加载项目站点
      $scope.project.loadStations null, (err, stations)=>
        dataCenters = _.filter stations, (sta)->(sta.model.parent is null or sta.model.parent is "") and sta.model.station.charAt(0) isnt "_"
        $scope.predicts = dataCenters
        $scope.stations = dataCenters
        $scope.station = dataCenters[0]
        $scope.parents = []

      # 选择站点
      $scope.selectStation = (station)=>
        $scope.station = station

      # 选择子站点
      $scope.selectChild = (station)=>
        $scope.stations = $scope.station.stations
        $scope.parents.push $scope.station
        $scope.station = station

      # 选择父站点
      $scope.selectParent = (station)=>
        index = $scope.parents.indexOf(station)
        $scope.parents.splice index, $scope.parents.length-index
        $scope.station = station
        $scope.stations = station.parentStation?.stations ? $scope.predicts

      preview.bind 'click', ()=>
        input.click()

      input.bind 'change', (evt) =>
        if @commonService.uploadService
          uploadImage input[0]?.files?[0]
        evt.target.value = null
        return

      # 上传图片
      uploadImage = (file) =>
        return if not file
        # upload image
        url = "#{$scope.dir}/#{file.name}"
        # give filename then resource service doesn't append timestamp to file name
        @commonService.uploadService.upload file, $scope.filename, url, (err, resource) ->
          if err
            console.log err
          else
            # add a random number to enforce to refresh
            $scope.equipment.model.image = "#{resource.resource}#{resource.extension}?#{new Date().getTime()}"
        , (progress) ->
          $scope.progress = progress * 100
        return

      # 删除图片
      $scope.delete = () =>
        $scope.equipment.model.image = ""
        return

      # 加载所有的用户
      loadAllUsers = () =>
        userService = @commonService.modelEngine.modelManager.getService 'users'
        filter = {}
        fields = null
        userService.query filter, fields, (err, data) =>
          if not err
            $scope.userMsg = data

      # 监听站点变化
      $scope.$watch 'station', (station)=>
        $scope.detail = false
        $scope.editShow = false
        $scope.assetShow = false
        $scope.addShow = true
        $scope.add = false
        $scope.currentType = null
        $scope.childStations = []
        #loadAllChildStation()
        loadStatisticByEquipmentTypes()
        loadAllUsers()
        if !$scope.subscribeReturnList
          $scope.subscribeReturnList?dispose()
          $scope.subscribeReturnList = @subscribeEventBus 'backList', (msg) =>
            $scope.editShow = false
            $scope.assetShow = false
            $scope.addShow = true

      # 加载设备类型
      loadStatisticByEquipmentTypes = () =>
        getStationEquipTypes (equipTypeDatas)=>
          stationType = {
            statistic:{}
          }

          for equipTypeDataItem in equipTypeDatas
            for j, item of equipTypeDataItem.statistic
              it = _.findWhere stationType.statistic, {type: item.type}
              if it
                it.count = it.count + item.count
              else
                stationType.statistic[item.type] = item
          processTypes stationType, true

      #获取所有站点类型
      getStationEquipTypes = (callback) =>
        @allInventoryStations = []
        @getAllStations $scope,$scope.station.model.station
        allInventoryStationsLen = @allInventoryStations.length
        allInventoryStationsCount = 0
        allEquipModels = []

        for stationObj in @allInventoryStations
          stationObj.loadStatisticByEquipmentTypes  (err, mod)->
            allEquipModels.push mod
            allInventoryStationsCount++
            if allInventoryStationsCount == allInventoryStationsLen
              callback? allEquipModels
          , true

      # 对设备类型进行处理
      processTypes = (data, refresh) =>
        return if not data?.statistic
        types = []
        for key, value of data.statistic when value.type[0] isnt '_' #and value.base
          types.push value
        _.map types, (type)=>
          currentType = _.find $scope.project.dictionary.equipmenttypes.items, (item) => item.model.type is type.type
          if currentType.model.image
            type.image = currentType.model.image
        $scope.equipTypes = types
        typesArr = _.filter $scope.equipTypes, (type)=>
          return type.count isnt 0 and type.type isnt 'KnowledgeDepot'
        if !$scope.currentType
          $scope.currentType = typesArr[0]
        selectType $scope.currentType.type, null , refresh

      # 加载特定类型的设备
      selectType = (type, callback, refresh) =>
        return if not type
        $scope.equipments = []
        getStationEquipment = (station, callback) =>
          for sta in station.stations
            getStationEquipment sta, callback
          @commonService.loadEquipmentsByType station, type, (err, mods) =>
            callback? mods
          , refresh
        getStationEquipment $scope.station, (equips) =>
          diff = _.difference equips, $scope.equipments
          $scope.equipments = $scope.equipments.concat diff
          $scope.$applyAsync()
          for equip in equips
            equip.loadProperties()
            equip.model.typeName = (_.find $scope.project.dictionary.equipmenttypes.items, (type)->type.key is equip.model.type)?.model.name
            equip.model.templateName = (_.find $scope.project.equipmentTemplates.items, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
            equip.model.vendorName = (_.find $scope.project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
            equip.model.stationName = (_.find $scope.project.stations.items, (station)->station.model.station is equip.model.station)?.model.name

      # 选择设备类型
      $scope.selectEquipType = (type) =>
        $scope.pageIndex = 1
        $scope.detail = false
        $scope.editShow = false
        $scope.assetShow = false
        $scope.addShow = true
        $scope.currentType = type
        selectType $scope.currentType.type, null, false

      # 选择设备
      $scope.selectEquip = (equipment) =>
        $scope.equipment = equipment
        setEquipmentData()

      # 格式化设备的数据
      setEquipmentData = () =>
        _.map $scope.equipment.properties.items, (item) =>
          if item.model.property is 'status'
            $scope.equipment.model.status = item.value
            statusArr = item.model.format.split(',')
            for lt in statusArr
              if lt.split(":")[0] is item.value or lt.split(":")[1] is item.value
                $scope.equipment.model.statusName = lt.split(":")[1]
                item.model.value = lt.split(":")[1]
          if item.model.property is 'install-date'
            life = _.find $scope.equipment.properties.items, (item) ->
              return item.model.property is 'life'
            $scope.equipment.model.remainDate = life.value - moment().diff(item.value, 'months')
          if item.model.property is 'guarantee-month'
            if item.value
              install = _.find $scope.equipment.properties.items, (item) ->
                return item.model.property is 'install-date'
              $scope.equipment.model.repairDate = item.value - moment().diff(install.value, 'months') % item.value
            else
              $scope.equipment.model.repairDate = 0

          if _.isNaN($scope.equipment.model.remainDate)
            $scope.equipment.model.remainDate = '-'
          if _.isNaN($scope.equipment.model.repairDate)
            $scope.equipment.model.repairDate = '-'
      # 导入资产视图
      $scope.importAssets = () =>
        $scope.editShow = false
        $scope.assetShow = true
        $scope.addShow = false
      # 切换视图
      $scope.switchView = () =>
        $scope.view = !$scope.view
        $scope.pageIndex = 1
        if $scope.view
          $scope.pageItems = 12
          $scope.viewName = '列表'
        else
          $scope.pageItems = 8
          $scope.viewName = '视图'

      # 选择页数
      $scope.selectPage = (page)=>
        $scope.pageIndex = page

      # 设备模板的图片
      $scope.imgString = (templateId) =>
        #console.log(templateId)
        url = ""
        template = _.find $scope.project.equipmentTemplates.items, (item) => item.model.template is templateId
        #console.log(template)
        if template and template.model.image
          url = "url('#{$scope.setting.urls.uploadUrl}/#{template.model.image}')"
        else
          url = "url('#{$scope.noEquipImg}')"
        return url

      # 返回到设备列表
      $scope.backList = ()=>
        $scope.equipment = null
        $scope.detail = false
        $scope.editShow = false
        $scope.assetShow = false
        $scope.addShow = true
        $scope.add = false

      # 保存设备信息
      $scope.saveEquipment = () =>
        return
        $scope.equipment.save (err, model) =>
          loadStatisticByEquipmentTypes()

      $scope.saveEquipment = (obj) =>
#        $scope.equipment.model.enable = !$scope.equipment.model.enable
        $scope.equipment.save (err, model) =>
          loadStatisticByEquipmentTypes()

      # 获取设备的名称
      getNextName = (name, defaultName="") ->
        # find the last number in the name and increase 1
        return defaultName if not name
        name2 = name.replace /(\d*$)/, (m, p1) ->
          num = if p1 then parseInt(p1) + 1 else '-0'
        return name2

      # 复制设备
      $scope.copyEquipment = (equip) =>
        return if not equip
        $scope.add = true
        $scope.editShow = true
        $scope.assetShow = false
        $scope.addShow = false
        model =
          equipment: getNextName equip.model.equipment
          name: getNextName equip.model.name
          type: equip.model.type
          template: equip.model.template
          vendor: equip.model.vendor
          owner: equip.model.owner
          image: equip.model.image
          desc: equip.model.desc
        $scope.equipment = $scope.station?.createEquipment model, equip?.parentElement
        $scope.equipment.propertyValues = angular.copy equip.propertyValues
        $scope.equipment.sampleUnits = angular.copy equip.sampleUnits
        $scope.equipment.properties.items = equip.properties.items
        $scope.settingEquipId()
        $scope.$applyAsync()
        $scope.equipment

      # 新增设备
      $scope.addEquipment = () =>
        $scope.add = true
        $scope.editShow = true
        $scope.assetShow = false
        $scope.addShow = false
        $scope.equipment = $scope.station.createEquipment null
        $scope.equipment.model.type = $scope.currentType.type

      # 监听站点变化
      $scope.stationChange = () =>
        $scope.settingEquipId()

      # 监听设备类型变化
      $scope.equipTypeChange = () =>
        $scope.currentType = _.find $scope.equipTypes, (type) => type.type is $scope.equipment.model.type
        $scope.settingEquipId()
        #selectType $scope.equipment.model.type, null, false

      # 监听设备厂商变化
      $scope.equipVendorChange = () =>
        $scope.settingEquipId()

      # 监听设备模板变化
      $scope.equipTemplateChange = () =>
        console.info $scope.equipment
        $scope.settingEquipId()

      # 设置设备的参数
      $scope.settingEquipId = () =>
        return if not $scope.equipment.model.station or not $scope.equipment.model.type or not $scope.equipment.model.vendor or not $scope.equipment.model.template
        template = $scope.equipment.model.template
        equipmentTemplate = _.find $scope.project.equipmentTemplates.items, (item) ->
          return item.model.template is template
        equipmentTemplate?.loadProperties null, (err, result)=>
          _.each result, (item) ->
            if item.model.dataType is 'date' or item.model.dataType is 'time' or item.model.dataType is 'datetime'
              item.model.value = moment(item.model.value).toDate()
            item.value = item.model.value
          $scope.equipment._properties = result
        $scope.equipment._sampleUnits = equipmentTemplate?.model.sampleUnits
        name = equipmentTemplate?.model.name.replace /模板/, ''
        loadEquipsByAdd (num) =>
          equipID = $scope.equipment.model.type + '-' + $scope.equipment.model.template + '-' + num
          equipName = name + '-' + num
          $scope.equipment.model.equipment = equipID
          $scope.equipment.model.name = equipName
          settingEquipSampleUnits()

      # 加载指定类型和模板设备
      loadEquipsByAdd = (callback) =>
        station = _.find $scope.project.stations.items, (station) => station.model.station is $scope.equipment.model.station
        filter =
          user: $scope.equipment.model.user
          project: $scope.equipment.model.project
          #station: $scope.equipment.model.station
          type: $scope.equipment.model.type
          template: $scope.equipment.model.template
        station.loadEquipments filter, null, (err, equips) =>
          return if err
          callback? getEquipNumber(equips)
        ,true

      # 获取指定类型和模板设备的编号
      getEquipNumber = (equips) =>
        i = 0
        _.map equips, (equip) ->
          arr = equip.model.equipment.split('-')
          str = arr[arr.length-1]
          num = str.replace(/[^0-9]/ig, "")
          if (num-i) > 0
            i = num
        i++
        result = i
        return result

      # 设置设备采集单元
      settingEquipSampleUnits = () =>
        mu = 'mu-' + $scope.equipment.model.user + '.' + $scope.equipment.model.project + '.' + $scope.equipment.model.station
        su = 'su-' + $scope.equipment.model.equipment
        $scope.equipment.model.sampleUnits = []
        _.each $scope.equipment._sampleUnits, (sampleUnits) =>
          sampleUnits.value = mu + '/' + su
          sample = {}
          sample.id = sampleUnits.id
          sample.value = mu + '/' + su
          $scope.equipment.model.sampleUnits.push sample
          $scope.equipment.sampleUnits[sampleUnits.id] = sampleUnits
        return

      # 保存新增设备
      $scope.saveEquipmentGroups = () =>
        $scope.add = false
        $scope.editShow = false
        $scope.assetShow = false
        $scope.addShow = true
        $scope.detail = false
        $scope.currentType = _.find $scope.equipTypes, (type) =>
          return type.type is $scope.equipment.model.type
        $scope.saveEquipment()

      # 删除设备
      $scope.deleteEquip = (equip)=>
        $scope.equipment = equip
        title = "删除设备确认: #{$scope.project.model.name}/#{$scope.station.model.name}/#{$scope.equipment.model.name}"
        message = "请确认是否删除设备: #{$scope.project.model.name}/#{$scope.station.model.name}/#{$scope.equipment.model.name}？删除后设备和数据将从系统中移除不可恢复！"
        $scope.prompt title, message, (ok) =>
          return if not ok
          $scope.equipment.remove (err, model) =>
            loadStatisticByEquipmentTypes()

      # 编辑设备数据
      $scope.editData = (equipment) =>
        console.info equipment
        $scope.editShow = true;
        $scope.assetShow = false
        $scope.addShow = false
        if equipment
          $scope.equipment = equipment
        setEquipmentData()

      # 保存旧数据
      $scope.saveValue = (value) =>
        $scope.oldValue = value

      # 检查数据是否有变化
      $scope.checkValue = (value) =>
        if $scope.oldValue is value
          return
        else
          $scope.saveEquipment()

      # 监听设备图片变化
      $scope.$watch 'equipment.model.image', ()=>
        if $scope.editShow and !$scope.add
          $scope.saveEquipment()

      # 检测站点变化
      $scope.stationCheck = () =>
        if $scope.equipment.model.station
          $scope.saveEquipment()

      # 查看设备数据
      $scope.lookData = (equipment) =>
        $scope.editShow = false;
        $scope.assetShow = false
        $scope.addShow = true
        $scope.detail = true;
        if equipment
          $scope.equipment = equipment
        setEquipmentData()

      # 过滤设备类型-设备类型
      $scope.filterTypes = () =>
        (type)=>
          return type.count isnt 0 and type.type isnt 'KnowledgeDepot'

      # 过滤设备-设备列表
      $scope.filterEquipment = () =>
        (equipment) =>
          text = $scope.searchLists?.toLowerCase()
          if not text
            return true
          if equipment.model.equipment?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.tag?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.typeName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.stationName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.vendorName?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      # 对设备进行分页设置
      $scope.filterEquipmentItem = ()=>
        return if not $scope.equipments
        items = []
        items = _.filter $scope.equipments, (equipment) =>
          text = $scope.searchLists?.toLowerCase()
          if not text
            return true
          if equipment.model.equipment?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.tag?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.typeName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.stationName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.vendorName?.toLowerCase().indexOf(text) >= 0
            return true
          return false
        pageCount = Math.ceil(items.length / $scope.pageItems)
        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制每页的个数
      $scope.limitToEquipment = () =>
        if $scope.filterEquipmentItem() and $scope.filterEquipmentItem().pageCount is $scope.pageIndex
          aa = $scope.filterEquipmentItem().items % $scope.pageItems;
          result = -(if aa==0 then $scope.pageItems else aa)
        else
          result = -$scope.pageItems
        result

      # 搜索设备属性-设备详情
      $scope.filterProperties = ()->
        (item) =>
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.dataType is "image" or item.model.visible is false
            return false
          text = $scope.searchDetail?.toLowerCase()
          if not text
            return true
          if item.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if item.model.property?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      # 搜索设备属性-设备编辑
      $scope.filterEditItems1 = ()=>
        (item)=>
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.visible is false
            return false
          if item.model.property is 'production-time' or item.model.name is '生产日期'
            return true
          if item.model.property is 'buy-date' or item.model.name is '购买日期'
            return true
          if item.model.property is 'install-date' or item.model.name is '安装日期'
            return true
          return false

      # 搜索设备属性-设备编辑
      $scope.filterEditItems2 = ()=>
        (item)=>
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.visible is false
            return false
          if item.model.property is 'production-time' or item.model.name is '生产日期'
            return false
          if item.model.property is 'buy-date' or item.model.name is '购买日期'
            return false
          if item.model.property is 'install-date' or item.model.name is '安装日期'
            return false
          text = $scope.searchEdit?.toLowerCase()
          if not text
            return true
          if item.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if item.model.property?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      # 过去设备模板
      $scope.filterEquipmentTemplate = ()=>
        (template) =>
          return false if not $scope.equipment
          model = $scope.equipment.model
          return template.model.type is model.type and template.model.vendor is model.vendor

    getAllStations:(refScope,refStation)=>
      stationResult = _.filter refScope.project.stations.items,(stationItem)->
        return stationItem.model.station == refStation
      for stationResultItem in stationResult
        childStations = _.filter refScope.project.stations.items,(stationItem)->
          return stationItem.model.parent == refStation
        @allInventoryStations.push stationResultItem
        if !childStations
          return

        for childStationsItem in childStations
          @getAllStations(refScope,childStationsItem.model.station)


    resize: ($scope)->

    dispose: ($scope)->
      $scope.subscribeReturnList?dispose()


  exports =
    InventoryManageDirective: InventoryManageDirective