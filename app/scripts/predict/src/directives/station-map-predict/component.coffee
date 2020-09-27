###
* File: station-map-predict-directive
* User: sheen
* Date: 2020/03/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'echarts'], (base, css, view, _, moment, echarts) ->
  class StationMapPredictDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-map"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.data = []
      scope.geoCoordMap = {}  #所有站点坐标
      scope.geoCoord = []  # 中心站点坐标
      scope.times = ""
      e = element.find('.echartsContent')
      scope.myChart?.dispose()
      scope.myChart = null
      scope.myChart = echarts.init(e[0])
      scope.levelColorMap = {
        '1': 'rgba(241, 109, 115, .8)',
        '2': 'rgba(255, 235, 59, .7)',
        '3': 'rgba(147, 235, 248, 1)'
      }
      @loadStations(scope)
      # 跳转页面
      scope.jumpPage = (station) =>
        return if station.station is 'china'
        window.location.hash = "#/station-info/#{scope.project.model.user}/#{scope.project.model.project}/#{station.station}"

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
        scope.times = "#{scope.day} #{scope.time} #{scope.date}"
        @initMapData(scope)
      ,60000)
# 获取所有站点
    loadStations:(scope)=>
# 获取所有站点
      scope.project.loadStations null, (err, stations)=>
        scope.stations = stations
        if(scope.stations.length>0)
          @setStationData(scope)
#处理站点数据让其符合地图展示的数据
    setStationData:(scope)=>
      for sta in scope.stations
        @getDevices scope,sta ,(d)=>
          @initMapData(scope)
        scope.geoCoordMap[sta.model.name] = [sta.model.longitude,sta.model.latitude]
        if !sta.model.parent
          scope.geoCoord = [sta.model.longitude,sta.model.latitude]
# 获取设备总数
    getDevices: (scope,site,callback) =>
      if site.model.parent != ''
        site.loadEquipments null, null, (err, equipments)=>
          newEquips = []
          for item in equipments
            if item.model.type != "_station_management"
              newEquips.push(item)
          dataValue = {station:'',name:'',value:0}
          dataValue.station = site.model.station
          dataValue.name = site.model.name
          dataValue.value = @addZero(newEquips.length)
          scope.data.push dataValue
          callback? scope.data
      else
        newEquips = []
        index = 0
        dataValue = {station:'',name:'',value:0}
        dataValue.station = site.model.station
        dataValue.name = site.model.name
        for sta in site.stations
          index++
          sta.loadEquipments null, null, (err, equipments)=>
            for item in equipments
              if item.model.type != '_station_management'
                newEquips.push item
            if index = site.stations.length
              dataValue.value = newEquips.length
              scope.data.push dataValue
              callback? scope.data


    addZero:(num)=>
      if (parseInt(num) < 10 and parseInt(num)>0)
        num = '0' + num
      return num
    # 处理地图数据
    convertData:(scope,data)=>
      res = []
      for i in data
        geoCoord = scope.geoCoordMap[i.name]
        if(geoCoord)
          res.push({station:i.station,name:i.name, value: geoCoord.concat(i.value)})
      return res
    convertData2: (scope,data) =>
      res = []
      for i in data
        geoCoord = scope.geoCoordMap[i.name]
        toCoord = scope.geoCoordMap[i.name] if i.station is 'china'
        if(geoCoord and i.name isnt '华新水泥')
          res.push(
            [
              {coord:geoCoord,value:i.value},
              {coord:toCoord}
            ]
            )
      return res

# 地图数据展示
    initMapData:(scope) =>
      zhongguo = "/lib/echarts/map/json/china.json"
      series = []
      echarts.extendsMap = (id, opt)=>
#        console.log '-----data--',scope.data
        [['华新水泥', scope.data]].forEach( (item, i) =>
          series.push(
            {
              type: 'lines',
              zlevel: 2,
              effect:
                show: true,
                period: 4,
                trailLength: 0.02,
                symbol: 'arrow',
                symbolSize: 5,
              lineStyle:
                normal:
                  color: '#0faa57'
                  width: 1,
                  opacity: 1,
                  curveness: .3
              data: @convertData2(scope,item[1])
            }
            {
              type: 'effectScatter',
              coordinateSystem: 'geo',
              zlevel: 2,
              rippleEffect:
                brushType: 'stroke'
              symbol: 'circle'
#              symbol: 'image://data:image/png;base64,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'
              symbolSize: 10
              hoverAnimation: false
              label:
                normal:
                  color: '#fff'
                  formatter: (params)=>
                    if typeof(params.value)[2] == "undefined"
                      return  ' ' + params.name + '(' + params.value + ')'
                    else
                      return ' ' + params.name + '(' + params.value[2] + ')';
                  position: 'right'
                  show: true
                emphasis:
                  show: true
#              itemStyle:
#                normal:
#                  color: (params)=>
#                    return scope.levelColorMap[3]
              itemStyle:
                normal:
                  color: scope.levelColorMap[3]
              data: _.filter (item[1].map( (dataItem)->
                return {
                  station: dataItem.station
                  name: dataItem.name,
                  value: scope.geoCoordMap[dataItem.name].concat([dataItem.value])
                };
              )),(d)-> d.station isnt 'china'
            }
            {
              type: 'scatter',
              coordinateSystem: 'geo',
              zlevel: 2,
              symbol: 'image://data:image/png;base64,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'
              symbolSize: 16
              hoverAnimation: false
              label:
                normal:
                  color: '#fff'
                  formatter: (params)=>
                    if typeof(params.value)[2] == "undefined"
                      return  ' ' + params.name + '(' + params.value + ')'
                    else
                      return ' ' + params.name + '(' + params.value[2] + ')';
                  position: 'right'
                  show: true
                emphasis:
                  show: true
              itemStyle:
                normal:
                  color: (params)=>
                    return scope.levelColorMap[3]
              data: [{
                station: 'china'
                name: item[0],
                value: scope.geoCoordMap[item[0]].concat([(_.find(item[1],(d)->d.station is 'china')).value]),
              }],
          }

          )
        )


        option =
          title :
            text: '华新水泥全国厂区站点概览图'
            subtext: scope.times
            x: 'center'
            y:"4%"
            textStyle:
              color: '#F3F6FE'
              fontSize: 28
            subtextStyle:
              color: '#F3F6FE'
              fontSize: 18
          tooltip:
            trigger: 'item'
            formatter: (params)=>
#              if typeof(params.value)[2] == "undefined"
##                return params.name + ' : ' + params.value
##              else
##                return params.name + ' : ' + params.value[2];
            formatter: (params, ticket, callback)->
              if (params.seriesType in ["scatter","effectScatter"])
                return params.name + ' : ' + params.value[2];
              else if(params.seriesType=="lines")
                return params.data.value
              else
                return params.name;


          geo:
            map: opt.mapName
            show: true
            roam: true
            label:
              normal:
                show: false
              emphasis:
                show: false
            itemStyle:#地图区域的多边形 图形样式
              normal:#是图形在默认状态下的样式
                areaColor: '#02204E'
                borderColor: '#004E8D'
              emphasis:
                areaColor: '#004E8D' #是图形在高亮状态下的样式,比如在鼠标悬浮或者图例联动高亮时
          series: series
        scope.myChart.setOption option
        # 添加事件
        scope.myChart.on 'click', (params) =>
          if params.componentType is "series"
            scope.jumpPage(params.data)

      $.getJSON zhongguo, (geoJson)=>
        echarts.registerMap('china', geoJson)
        myChart = echarts.extendsMap 'map', {
          bgColor: 'transparent'
          mapName: 'china'
          text: ''
          goDown: false
          callback: (name, option, instance)=>
        }

    resize: (scope)->
      scope.myChart?.resize()

    dispose: (scope)->
      scope.myChart?.dispose()
      clearInterval scope.interval

  exports =
    StationMapPredictDirective: StationMapPredictDirective