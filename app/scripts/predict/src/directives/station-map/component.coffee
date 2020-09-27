###
* File: station-map-directive
* User: bingo
* Date: 2019/06/19
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'echarts'], (base, css, view, _, moment, echarts) ->
  class StationMapDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-map"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      # 地图数据展示
      initMapData = (mapData, geoCordMap) ->
        zhongguo = "/lib/echarts/map/json/china.json"
        anhui = "/lib/echarts/map/json/province/anhui.json"
        aomen = "/lib/echarts/map/json/province/aomen.json"
        beijing = "/lib/echarts/map/json/province/beijing.json"
        chongqing = "/lib/echarts/map/json/province/chongqing.json"
        fujian = "/lib/echarts/map/json/province/fujian.json"
        gansu = "/lib/echarts/map/json/province/gansu.json"
        guangdong = "/lib/echarts/map/json/province/guangdong.json"
        guangxi = "/lib/echarts/map/json/province/guangxi.json"
        guizhou = "/lib/echarts/map/json/province/guizhou.json"
        hainan = "/lib/echarts/map/json/province/hainan.json"
        heilongjiang = "/lib/echarts/map/json/province/heilongjiang.json"
        henan = "/lib/echarts/map/json/province/henan.json"
        hebei = "/lib/echarts/map/json/province/hebei.json"
        hubei = "/lib/echarts/map/json/province/hubei.json"
        hunan = "/lib/echarts/map/json/province/hunan.json"
        jiangsu = "/lib/echarts/map/json/province/jiangsu.json"
        jiangxi = "/lib/echarts/map/json/province/jiangxi.json"
        jilin = "/lib/echarts/map/json/province/jilin.json"
        liaoning = "/lib/echarts/map/json/province/liaoning.json"
        neimenggu = "/lib/echarts/map/json/province/neimenggu.json"
        ningxia = "/lib/echarts/map/json/province/ningxia.json"
        qinghai = "/lib/echarts/map/json/province/qinghai.json"
        shangdong = "/lib/echarts/map/json/province/shandong.json"
        shanghai = "/lib/echarts/map/json/province/shanghai.json"
        shangxi = "/lib/echarts/map/json/province/shanxi.json"
        shanxi = "/lib/echarts/map/json/province/shanxi1.json"
        sichuan = "/lib/echarts/map/json/province/sichuan.json"
        taiwan = "/lib/echarts/map/json/province/taiwan.json"
        tianjin = "/lib/echarts/map/json/province/tianjin.json"
        xianggang = "/lib/echarts/map/json/province/xianggang.json"
        xinjiang = "/lib/echarts/map/json/province/xinjiang.json"
        xizang = "/lib/echarts/map/json/province/xizang.json"
        yunnan = "/lib/echarts/map/json/province/yunnan.json"
        zhejiang = "/lib/echarts/map/json/province/zhejiang.json"

        echarts.extendsMap = (id, opt)=>
          #$scope.myChart = echarts.init(document.getElementById(id))
          curGeoJson = {}
          cityMap = {
            '中国': zhongguo,
            '上海': shanghai,
            '河北': hebei,
            '山西': shangxi,
            '内蒙古': neimenggu,
            '辽宁': liaoning,
            '吉林': jilin,
            '黑龙江': heilongjiang,
            '江苏': jiangsu,
            '浙江': zhejiang,
            '安徽': anhui,
            '福建': fujian,
            '江西': jiangxi,
            '山东': shangdong,
            '河南': henan,
            '湖北': hubei,
            '湖南': hunan,
            '广东': guangdong,
            '广西': guangxi,
            '海南': hainan,
            '四川': sichuan,
            '贵州': guizhou,
            '云南': yunnan,
            '西藏': xizang,
            '陕西': shanxi,
            '甘肃': gansu,
            '青海': qinghai,
            '宁夏': ningxia,
            '新疆': xinjiang,
            '北京': beijing,
            '天津': tianjin,
            '重庆': chongqing,
            '香港': xianggang,
            '澳门': aomen,
            '台湾': taiwan
          }
          defaultOpt =
            mapName: 'china',
            goDown: false,
            bgColor: 'transparent',
            activeArea: [],
            data: [],
            callback: (name, option, instance)=>
          if (opt)
            opt = echarts.util.extend(defaultOpt, opt)
          name = [opt.mapName]
          idx = 0
          pos =
            leftPlus: 115,
            leftCur: 150,
            left: '8%',
            top: 50
          style =
            font: '18px "Microsoft YaHei", sans-serif',
            textColor: '#eee',
            lineColor: 'rgba(147, 235, 248, .8)'
          line = [
            [0, 0],
            [8, 11],
            [0, 22]
          ]
          handleEvents =
            # 重新设置option
            resetOption: (chart, option, mapName)=>
              breadcrumb = handleEvents.createBreadcrumb(mapName)
              j = name.indexOf(mapName)
              l = option.graphic.length
              if j < 0
                option.graphic.push(breadcrumb)
                option.graphic[0].children[0].shape.x2 = 145
                option.graphic[0].children[1].shape.x2 = 145
                if option.graphic.length > 2
                  cityData = []
                  for i in [0...opt.data.length]
                    if mapName is opt.data[i].name
                      $([opt.data[i]]).each (index, data) =>
                        cityJson = {name: data.name, stationName: data.stationName, station: data.station, value: data.value, selected: true};
                        cityData.push(cityJson)
                  if cityData
                    option.series[0].data = handleEvents.initSeriesData(cityData)
                  else
                    option.series[0].data = []
                name.push mapName
                idx++
              else
                option.graphic.splice(j + 2, l)
                if (option.graphic.length <= 2)
                  option.graphic[0].children[0].shape.x2 = 60
                  option.graphic[0].children[1].shape.x2 = 60
                  option.series[0].data = handleEvents.initSeriesData(opt.data)
                name.splice(j + 1, l)
                idx = j
                pos.leftCur -= pos.leftPlus * (l - j - 1)
              option.geo.map = mapName
              option.geo.zoom = 0.4
              chart.clear()
              chart.setOption(option)
              handleEvents.zoomAnimation()
              opt.callback(mapName, option, chart)

            # 创建graphic
            createBreadcrumb: (name)=>
              cityToPinyin = {
                '中国': 'zhongguo',
                '上海': 'shanghai',
                '河北': 'hebei',
                '山西': 'shangxi',
                '内蒙古': 'neimenggu',
                '辽宁': 'liaoning',
                '吉林': 'jilin',
                '黑龙江': 'heilongjiang',
                '江苏': 'jiangsu',
                '浙江': 'zhejiang',
                '安徽': 'anhui',
                '福建': 'fujian',
                '江西': 'jiangxi',
                '山东': 'shangdong',
                '河南': 'henan',
                '湖北': 'hubei',
                '湖南': 'hunan',
                '广东': 'guangdong',
                '广西': 'guangxi',
                '海南': 'hainan',
                '四川': 'sichuan',
                '贵州': 'guizhou',
                '云南': 'yunnan',
                '西藏': 'xizang',
                '陕西': 'shanxi',
                '甘肃': 'gansu',
                '青海': 'qinghai',
                '宁夏': 'ningxia',
                '新疆': 'xinjiang',
                '北京': 'beijing',
                '天津': 'tianjin',
                '重庆': 'chongqing',
                '香港': 'xianggang',
                '澳门': 'aomen'
              }
              breadcrumb =
                type: 'group'
                id: name,
                left: pos.leftCur + pos.leftPlus,
                top: pos.top + 3,
                children: [
                  {
                    type: 'polyline',
                    left: -90,
                    top: -5,
                    shape: {
                      points: line
                    },
                    style: {
                      stroke: '#fff',
                      key: name
                    },
                    onclick: =>
                      name = this.style.key;
                      handleEvents.resetOption($scope.myChart, option, name);
                  },
                  {
                    type: 'text',
                    left: -68,
                    top: 'middle',
                    style:
                      text: name,
                      textAlign: 'center',
                      fill: style.textColor,
                      font: style.font
                    onclick: =>
                      name = this.style.text;
                      handleEvents.resetOption($scope.myChart, option, name);
                  },
                  {
                    type: 'text',
                    left: -68,
                    top: 10,
                    style:
                      name: name,
                      text: if cityToPinyin[name] then cityToPinyin[name].toUpperCase() else ''
                      textAlign: 'center',
                      fill: style.textColor,
                      font: '12px "Microsoft YaHei", sans-serif',
                    onclick: =>
                      name = this.style.name;
                      handleEvents.resetOption($scope.myChart, option, name);
                  }
                ]
              pos.leftCur += pos.leftPlus
              breadcrumb
            # 设置点
            initSeriesData: (data)=>
              temp = []
              for i in [0...data.length]
                geoCord = geoCordMap[data[i].station]
                if geoCord
                  temp.push {
                    city: data[i].name,
                    name: data[i].stationName,
                    station: data[i].station,
                    value: geoCord.concat(data[i].value)
                  }
              #console.log temp
              temp
            # 地图切换动画
            zoomAnimation: ()=>
              count = null
              zoom = (per)=>
                if !count
                  count = per
                count = count + per
                $scope.myChart.setOption {
                  geo: {
                    zoom: count
                  }
                }
                if count < 1
                  window.requestAnimationFrame ()=>zoom(0.2)
              window.requestAnimationFrame ()=>zoom(0.2)
          option =
            backgroundColor: opt.bgColor
            graphic: [
              {
                type: 'group',
                left: pos.left,
                top: pos.top - 4,
                children: [
                  {
                    type: 'line',
                    left: 0,
                    top: -20,
                    shape:
                      x1: 0,
                      y1: 0,
                      x2: 60,
                      y2: 0
                    style:
                      stroke: style.lineColor
                  },
                  {
                    type: 'line',
                    left: 0,
                    top: 20,
                    shape:
                      x1: 0,
                      y1: 0,
                      x2: 60,
                      y2: 0
                    style:
                      stroke: style.lineColor
                  }
                ]
              },
              {
                id: name[idx],
                type: 'group',
                left: pos.left,
                top: pos.top,
                children: [
                  {
                    type: 'polyline',
                    left: 90,
                    top: -12,
                    shape:
                      points: line
                    style:
                      stroke: 'transparent',
                      key: name[0]
                    onclick: ()=>
                      name = this.style.key
                      handleEvents.resetOption($scope.myChart, option, name)
                  },
                  {
                    type: 'text',
                    left: 0,
                    top: 'middle',
                    style:
                      text: '中国',
                      textAlign: 'center',
                      fill: style.textColor,
                      font: style.font
                    onclick: ()=>
                      handleEvents.resetOption($scope.myChart, option, '中国')
                  },
                  {
                    type: 'text',
                    left: 0,
                    top: 10,
                    style:
                      text: 'China',
                      textAlign: 'center',
                      fill: style.textColor,
                      font: '12px "Microsoft YaHei", sans-serif'
                    onclick: ()=>
                      handleEvents.resetOption($scope.myChart, option, '中国')
                  }
                ]
              }
            ]
            tooltip:
              formatter: (params) =>
                name = params.name.split("-")[0];
                if( params.value[2] != null && params.value[2] != undefined && params.value[2] != 'NaN')
                  return name + "：" + params.value[2]
                else
                  return name
            geo:
              map: opt.mapName,
              roam: true,
              zoom: 1,
              left: "10%",
              label:
                normal:
                  show: false,
                  textStyle:
                    color: '#fff'
                emphasis:
                  show: false
                  textStyle:
                    color: '#fff'
              itemStyle: {
                normal: {
                  borderColor: 'rgba(0, 192, 255, 0.2)',
                  borderWidth: 3,
                  areaColor: 'rgba(13, 190, 255, 0.35)'
                },
                emphasis: {
                  borderColor: 'rgba(0, 192, 255, 1)',
                  borderWidth: 3,
                  areaColor:
                    type: 'radial',
                    x: 0.5,
                    y: 0.5,
                    r: 0.8,
                    colorStops: [
                      { offset: 0, color: 'rgba(13, 190, 255, 0.5)'},
                      { offset: 1, color: 'rgba(13, 190, 255, 0.9)'}
                    ],
                    globalCoord: false
                }
              }
              regions: mapData
            series: [
              {
                type: 'effectScatter',
                coordinateSystem: 'geo',
                zlevel: 2,
                rippleEffect: {
                  period:'4',
                  scale:'4',
                  brushType: 'stroke'
                },
                label: {
                  normal: {
                    show: false,
                    position: 'right',
                    formatter: (params) =>
                      str = params.data.name
                      #str = "告警数量：" + params.data.value[2]
                      #str = params.data.name + "\n" + "设备数量：" + params.data.value[2]
                      return str
                    textStyle:{
                      color:'#fff',
                      fontStyle: 'normal',
                      fontFamily: 'arial',
                      fontSize: 12,
                    }
                  }
                },
                tooltip:{
                  show: true,
                  formatter: (params) =>
                    item = params.name.split("-")[0];
                    if( params.value[2] != null && params.value[2] != undefined && params.value[2] != 'NaN')
                      return "#{params.data.name}<br/>告警数量：#{params.value[2]}"
#                      return params.data.name + "告警数量：" + params.value[2]
                      #return item + "告警数量：" + params.value[2]
                    else
                      return item
                },
                symbolSize: 8,
                itemStyle: {
                  normal: {
                    color: (params) =>
                      if params.value[2] > 0 then 'rgba(244, 67, 54, 1)' else 'rgba(1, 225, 233, 1)'
                  }
                }
                data: handleEvents.initSeriesData(_.filter opt.data, (item) => item.value == 0)
              }
              {
                type: 'effectScatter',
                coordinateSystem: 'geo',
                zlevel: 2,
                rippleEffect: {
                  period:'4',
                  scale:'4',
                  brushType: 'stroke'
                },
                label: {
                  normal: {
                    show: true,
                    position: 'right',
                    formatter: (params) =>
                      str = params.data.name
                      #str = "告警数量：" + params.data.value[2]
                      #str = params.data.name + "\n" + "设备数量：" + params.data.value[2]
                      return str
                    textStyle:{
                      color:'#fff',
                      fontStyle: 'normal',
                      fontFamily: 'arial',
                      fontSize: 12,
                    }
                  }
                },
                tooltip:{
                  show: true,
                  formatter: (params) =>
                    item = params.name.split("-")[0];
                    if( params.value[2] != null && params.value[2] != undefined && params.value[2] != 'NaN')
                      return "告警数量：" + params.value[2]
                    else
                      return item
                },
                symbolSize: 8,
                itemStyle: {
                  normal: {
                    color: {
                      type: 'radial',
                      x: 0.5,
                      y: 0.5,
                      r: 0.5,
                      colorStops: [{
                        offset: 0, color: 'rgba(244, 67, 54, 1)'
                      }, {
                        offset: 1, color: 'rgba(220, 121, 120, 1)'
                      }],
                      globalCoord: false
                    }
                  }
                }
                data: handleEvents.initSeriesData(_.filter opt.data, (item) => item.value > 0)
              }
              {
                type: 'scatter',
                coordinateSystem: 'geo',
                symbol: 'pin',
                zlevel: 6,
                label: {
                  normal: {
                    show: true,
                    formatter: (params) =>
                      str = params.data.name
                      #str = "告警数量：" + params.data.value[2]
                      #str = params.data.name + "\n" + "设备数量：" + params.data.value[2]
                      return params.data.value[2]
                    textStyle:{
                      color:'#fff',
                      fontStyle: 'normal',
                      fontFamily: 'arial',
                      fontSize: 9,
                    }
                  }
                },
                itemStyle: {
                  normal: {
                    color: '#F62157',
                  }
                },
                tooltip:{
                  show: false,
                },
                symbolSize: 40,
                data: handleEvents.initSeriesData(_.filter opt.data, (item) => item.station is $scope.current?.station)
              }
            ]
          $scope.myChart.setOption option
          $scope.myChart.on 'click', (params) =>
            #console.log(params)
            if params.componentType is "series"
              $scope.jumpPage(params.data)
            if opt.goDown and params.name isnt name[idx]
              if cityMap[params.name]
                url = cityMap[params.name]
                $.get url, (response)=>
                  curGeoJson = response
                  echarts.registerMap(params.name, response)
                  handleEvents.resetOption($scope.myChart, option, params.name)

        $.getJSON zhongguo, (geoJson)=>
          echarts.registerMap('china', geoJson)
          myChart = echarts.extendsMap 'map', {
            bgColor: 'transparent'
            mapName: 'china'
            text: ''
            goDown: false
            callback: (name, option, instance)=>
            data: mapData
          }

      # 统计设备数量
      calculateEquipCount = () =>
        $scope.statisticEquips =
          equips: 0
          online: 0
          alarm: 0
          standby: 0
          offline: 0
        _.mapObject $scope.stationData, (item, key)=>
          $scope.statisticEquips.equips += item.equips
          $scope.statisticEquips.online += item.online
          $scope.statisticEquips.alarm += item.alarm
          $scope.statisticEquips.standby += item.standby
          $scope.statisticEquips.offline += item.offline

      # 处理信号
      processSignal = (signal) =>
        if signal.model.signal is "alarms"
          _.map $scope.stationData, (item) =>
            if item.station is signal.station.model.station
              item.alarms = signal.data.value
          _.map mapData, (item)=>
            if item.station is signal.station.model.station
              item.value = signal.data.value
          initMapData(mapData, geoMap)
        if signal.model.signal is "onlines"
          _.map $scope.stationData, (item) =>
            if item.station is signal.station.model.station
              item.online = signal.data.value
          calculateEquipCount()
        if signal.model.signal is "alarm-equipments"
          _.map $scope.stationData, (item) =>
            if item.station is signal.station.model.station
              item.alarm = signal.data.value
          calculateEquipCount()
        if signal.model.signal is "standby-equipments"
          _.map $scope.stationData, (item) =>
            if item.station is signal.station.model.station
              item.standby = signal.data.value
          calculateEquipCount()
        if signal.model.signal is "stops"
          _.map $scope.stationData, (item) =>
            if item.station is signal.station.model.station
              item.offline = signal.data.value
          calculateEquipCount()
        #console.log($scope.stationData)

#        if signal.model.signal is "alarms"
#          _.map mapData, (item)=>
#            if item.station is signal.station.model.station
#              item.value = signal.data.value
#          initMapData(mapData, geoMap)
#        else
#          _.mapObject $scope.stationData, (item, key)=>
#            if item.station is signal.station.model.station
#              if signal.model.signal is "onlines"
#                item.online = signal.data.value
#              if signal.model.signal is "alarm"
#                item.alarm = signal.data.value
#              if signal.model.signal is "standby"
#                item.standby = signal.data.value
#              if signal.model.signal is "offline"
#                item.offline = signal.data.value

      # 站点数据初始化
      initStationData = () =>
        _.each $scope.project.dictionary.equipmenttypes.items, (type) =>
          if type.model.visible?
            if type.model.type.charAt(0) isnt "_" and type.model.visible
              equipTypes.push type.model.type
          else
            if type.model.type.charAt(0) isnt "_"
              equipTypes.push type.model.type
        stations = _.filter $scope.project.stations.items, (item) => item.model.station.charAt(0) isnt "_"
        _.each stations, (station)=>
          $scope.stationData.push {
            name: station.model.name
            station: station.model.station
            alarms: 0
            equips: 0
            online: 0
            alarm: 0
            standby: 0
            offline: 0
          }
          mapData.push {
            name: station.model.city || '广东'
            station: station.model.station
            stationName: station.model.name
            value: 0
            selected: true
          }
          temp = []
          temp[0] = station.model.longitude || 114.26664636
          temp[1] = station.model.latitude || 22.5639158872
          geoMap[station.model.station] = temp
          filter =
            user:  station.model.user
            project: station.model.project
            station: station.model.station
            type:
              $in: equipTypes
            template: {$nin:['card-sender', 'card_template', 'people_template']}
          station.loadEquipments filter, null, (err, equips) ->
            #console.log(equips)
            return if err or equips.length < 1
            _.map $scope.stationData, (item)=>
              if item.station is equips[0].model.station
                item.equips = equips.length
            calculateEquipCount()
          station.loadEquipment '_station_management', null, (err, equip)=>
            return if not equip or not equip.model.equipment
            $scope.subscribeStation[station.key]?.dispose()
            $scope.subscribeStation[station.key] = @commonService.subscribeEquipmentSignalValues equip, (signal) =>
              console.log(signal)
              return if not signal or not signal.data.value
              processSignal(signal)
              return
              if signal.model.signal is "alarms"
                #console.log(signal)
                _.map $scope.stationData, (item)=>
                  if item.station is signal.station.model.station
                    item.alarms = signal.data.value
                _.map mapData, (item)=>
                  if item.station is signal.station.model.station
                    item.value = signal.data.value
                initMapData(mapData, geoMap)
              if signal.model.signal is "onlines"
                #console.log(signal)
                _.mapObject $scope.stationData, (item, key)=>
                  if item.station is signal.station.model.station
                    item.online = signal.data.value

      $scope.subscribeStation = {}
      $scope.stationData = []
      $scope.statisticEquips =
        equips: 0
        online: 0
        alarm: 0
        standby: 0
        offline: 0
      $scope.current = null
      equipTypes = []
      mapData = []
      geoMap = {}
      e = element.find('.station-map')
      $scope.myChart?.dispose()
      $scope.myChart = null
      $scope.myChart = echarts.init(e[0])
      initStationData()
      #$scope.current = $scope.stationData[0] if $scope.stationData.length > 0
      initMapData(mapData, geoMap)

      # 选择站点
      $scope.selectStation = (station) =>
        $scope.current = station
        initMapData(mapData, geoMap)

      # 跳转页面
      $scope.jumpPage = (station) =>
        window.location.hash = "#/dashboard/#{$scope.project.model.user}/#{$scope.project.model.project}?station=#{station.station}"

      # 过滤站点
      $scope.filterStation = () =>
        (station) =>
          text = $scope.searchLists?.toLowerCase()
          if not text
            return true
          if station.station?.toLowerCase().indexOf(text) >= 0
            return true
          if station.name?.toLowerCase().indexOf(text) >= 0
            return true
          return false

    resize: ($scope)->
      $scope.myChart?.resize()

    dispose: ($scope)->
      $scope.myChart?.dispose()
      $scope.myChart = null
      _.mapObject $scope.subscribeStation, (value, key) =>
        value.dispose()

  exports =
    StationMapDirective: StationMapDirective