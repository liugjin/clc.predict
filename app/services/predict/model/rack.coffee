`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation', 'rx', 'underscore', './server'], (base, Rx, _, Server) ->
  class Rack extends base.Service
    constructor: (@model, @service) ->
      super @model
      @subject = new Rx.Subject
      @sceneSubject = new Rx.Subject
      @NOASSETFLAG = "---"
      @data = {}
      @uwei = {}
      @COLOR = {auto:"-1--1--1",off:"0-0-0", red: "1-0-0", green: "0-1-0", blue: "0-0-1", yellow: "3-5-0", purple: "3-0-5", cyan: "0-3-5", white: "3-4-5", redflash:"1000-0-0",greenflash:"0-1000-0", blueflash:"0-0-1000",yellowflash:"60-100-0",purpleflash:"60-0-100",cyanflash:"0-60-100", whiteflash:"60-80-100"}
      @LED={idle: @COLOR.red, uprack: @COLOR.blue, illegaluprack: @COLOR.blueflash, downrack:@COLOR.red, illegaldownrack:@COLOR.redflash, planuprack:@COLOR.green, plandownrack:@COLOR.yellow}
      @getRackProperty()
      @subscribeRack()

#    initialize: (callback) ->
#      setTimeout =>
#        @subscribeRack()
#        @getRackInfo()
#      ,500
#
#      super callback

    getRackProperty: ->
      @mu = @model.sampleUnits[0]?.value
      @service.getEquipmentProperty @model, "height", (val)=>
        @height = val ? 42                  #获取机柜高度，默认为42U
      @service.getEquipmentProperty @model, "has-u-locator", (val)=>
        @hasULocator = if val? then parseInt(val) else 0                 #获取机柜是否配置了U位条设备
      @service.getEquipmentProperty @model, "u-direction", (val)=>
        @udirection = if val? then parseInt(val) else 0                 #获取机柜U位条是否未按标准方向安装
      @service.getEquipmentProperty @model, "normal-temperature", (val)=>
        @NORMALTEMPERATURE = val ? 23     #获取机柜在温场模式下的正常温度值信息，默认为23度
      @service.equip.find {user:@model.user, project:@model.project, station:@model.station, parent:@model.equipment}, null, (err, models)=>
        return if err
        for model in models
          server = new Server.Server(model, @service, @)
          server.getInfo (svr)=>
            for row in [svr.row..svr.lrow]
              @uwei[row] = {server: svr}                      #标识出每一个U位上的服务器

#    getRackInfo: ->
#      topic = "signal-values/"+@model.user+"/"+@model.project+"/"+@model.station+"/"+@model.equipment+"/#"
#      reg = new RegExp /^u-[\d]*-asset$/
#      @signalSubscription = @service.subscribeToMqtt topic, {qos: 0}, (data) =>
#        return if not data.message
#        console.log "signal:", data
#        @data[data.message.signal] = data.message.value
#        if reg.test data.message.signal
#          data.message.uwei = parseInt data.message.signal.split("-")[1]
#          @subject.onNext data.message
#
#      topic2 = "command-values/"+@model.user+"/"+@model.project+"/"+@model.station+"/"+@model.equipment+"/#"
#      reg1 = new RegExp /^set-u-[\d]*-led$/
#      reg2 = new RegExp /^set-u-plan-[\d]*/
#      @commandSubscription = @service.subscribeToMqtt topic2, {qos: 0}, (data) =>
#        return if not data.message or data.message.phase isnt "executing"
#        console.log "command:", data
##        @setUValue "u-"+data.message.command.split('-')[2],
#        @sceneSubject.onNext data if data.message.command is "toggle-scene"
#        if reg2.test data.message.command
#          row = parseInt data.message.command.split('-')[3]
#          @uwei[row]?.planStatus = data        #U位计划状态，0表示无计划，1表示计划上架，2表示计划下架
#
#      topic3 = "event-values/"+@model.user+"/"+@model.project+"/"+@model.station+"/"+@model.equipment+"/#"
#      reg3 = new RegExp /^illegal-[\w]*-rack-[\d]*/
#      @eventSubscription = @service.subscribeToMqtt topic3, {qos: 0}, (data) =>
#        return if not data.message
#        console.log "event:", data
#        if reg3.test data.message.event
#          row = parseInt data.message.event.split('-')[3]
#          @uwei[row]?.illegalUpStatus = data.message.endTime is null if data.messgage.event.split('-')[1] is "up"       #U位非法上架状态
#          @uwei[row]?.illegalDownStatus = data.message.endTime is null if data.messgage.event.split('-')[1] is "down"   #U位非法下架状态

    setSignal: (data) ->
      return if not data?.message?.signal
      reg = new RegExp /^u-[\d]*-asset$/
      @data[data.message.signal] = data.message.value
      if reg.test data.message.signal
        data.message.uwei = parseInt data.message.signal.split("-")[1]
        @subject.onNext data.message

    setCommand: (data)->
      return if not data?.message?.command
      reg1 = new RegExp /^set-u-[\d]*-led$/
      reg2 = new RegExp /^set-u-plan-[\d]*/
      @sceneSubject.onNext data if data.message.command is "toggle-scene"
      if reg1.test data.message.command
        row = parseInt data.message.command.split('-')[2]
        r = _.find data.message.parameters, (it)->it.key is "r"
        g = _.find data.message.parameters, (it)->it.key is "g"
        b = _.find data.message.parameters, (it)->it.key is "b"
        @setUValue "u-"+row, "led", r?.value+"-"+g?.value+"-"+b?.value if !@udirection
        @setUValue "u-"+(43-row), "led", r?.value+"-"+g?.value+"-"+b?.value if @udirection

      if reg2.test data.message.command
        row = parseInt data.message.command.split('-')[3]
        @uwei[row]?.planStatus = data        #U位计划状态，0表示无计划，1表示计划上架，2表示计划下架

    setEvent: (data)->
      return if not data?.message?.event
      reg3 = new RegExp /^illegal-[\w]*-rack-[\d]*/
      if reg3.test data.message.event
        row = parseInt data.message.event.split('-')[3]
        @uwei[row]?.illegaluprack = !data.message.endTime? if data.message.event.split('-')[1] is "up"       #U位非法上架状态
        @uwei[row]?.illegaldownrack = !data.message.endTime? if data.message.event.split('-')[1] is "down"   #U位非法下架状态

    subscribeRack: ->
      @subject.subscribe (data)=>
        if data.value is @NOASSETFLAG
          @removeAssetFromRack data.uwei
        else
          val = data.value.substr 0, 13
          @addAssetToRack data.uwei, val
      @sceneSubject.subscribe (data) =>
        return if data.message.phase isnt "executing"
        value = data.message.parameters?[0]?.value
        console.log new Date(), " toggle scene to "+ value
        switch value
          when 0
            @switchToSpaceMode()
          when 1
            @switchToCapacityMode "space"
          when 2
            @switchToCapacityMode "power"
          when 3
            @switchToCapacityMode "cooling"
          when 4
            @switchToCapacityMode "weight"
          when 5
            @switchToHeatmapMode()
          when 6
            @switchToLedMode "auto"
          when 7
            @switchToLedMode "off"
        @setUValue "_", "scene", value if value?          #发布scene采集信息

        data.message.phase = "complete"
        data.message.endTime = new Date()
        @service.publishToMqtt data.topic, data.message, {qos:2, retain: true}

    removeAssetFromRack: (uwei) ->
      server = @uwei[uwei]?.server
      if server
        begin = parseInt server.row
        end = parseInt server.lrow
        server.removeFromRack @
        if @uwei[uwei].planStatus?.message?.parameters[0]?.value is 2 or @uwei[uwei]?.illegaluprack
          for u in [begin..end]
            @updateUStatus u, "down"
        else
          for u in [begin..end]
            @updateUStatus u, "illegalDown"

    addAssetToRack: (uwei, asset) ->
      if not @uwei[uwei]?.server or @uwei[uwei].server.model.type is "_server"
        console.log "asset:", asset, @uwei[uwei]
        @uwei[uwei]?.server?.removeFromRack @ if @uwei[uwei]?.server?.model?.tag isnt asset
        @findAsset asset, (server)=>
          if server
            srv = new Server.Server server, @service, @
            srv.addToRack @, uwei
            if @uwei[uwei]?.planStatus?.message?.parameters[0]?.value is 1
              for u in [srv.row..srv.lrow]
                @updateUStatus u, "up"
            else
              for u in [srv.row..srv.lrow]
                @updateUStatus u, "illegalUp"
          else
            @addNewAssetByAssetId uwei, asset

    addNewAssetByAssetId: (uwei, assetId) ->
      asset =
        user: @model.user
        project: @model.project
        station: @model.station
        type: "_server"
        template: "_server_1U"
        vendor: "hyiot"
        equipment: assetId
        name: assetId
        tag: assetId
        parent: @model.equipment
        commands: []
        events: []
        ports: []
        properties: [{id:'row', value: uwei }]
        sampleUnits: []
        enable: true
      server = new Server.Server asset, @service, @
      server.addToRack @, uwei
      @updateUStatus uwei, "illegalUp"

    findAsset: (assetId, callback) ->
      @service.equip.findOne {user:@model.user, project:@model.project, station:@model.station, tag: assetId}, null, (err, asset)=>
        return console.log err if err
        console.log "find asset:", assetId, " result:", asset
        callback? asset

    updateUStatus: (uwei, status) ->
      console.log "updateUStatus:", status, " in uwei:", uwei
      switch status
        when "up"
          flag = true
          ledColor = @LED.uprack
          iup = 0
          idown = 0
        when "illegalUp"
          ledColor = @LED.illegaluprack
          iup = 1
          idown = 0
        when "down"
          flag = true
          ledColor = @LED.downrack
          iup = 0
          idown = 0
        when "illegalDown"
          ledColor = @LED.illegaldownrack
          iup = 0
          idown = 1
        else
          ledColor = @LED.idle
          iup = 0
          idown = 0
      @uwei[uwei] ?= {}
      @uwei[uwei].illegaluprack = iup
      @uwei[uwei].illegaldownrack = idown
      @setUPlanStatus @uwei[uwei].planStatus, 0 if flag
      if @hasULocator
        console.log "set u controller:", uwei, " with color:", ledColor
        arr = ["r", "g", "b"]
        color = _.map ledColor.split("-"), (val, key)->
          {key: arr[key], value: parseInt(val)}
        @setULedColor "set-u-"+uwei+"-led", color

      @setUValue "u-"+uwei, "led", ledColor if !@udirection
      @setUValue "u-"+(43-uwei), "led", ledColor if @udirection
      @setUValue "u-"+uwei, "illegal-up-rack", iup
      @setUValue "u-"+uwei, "illegal-down-rack", idown

    setUPlanStatus: (data, value) ->
      return if not data
      topic = data.topic
      message = data.message
      message.parameters?[0]?.value = value
      @service.publishToMqtt topic, message, {qos: 0, retain: true}

    setULedColor: (command, value) ->
      topic = "command-values/"+@model.user+"/"+@model.project+"/"+@model.station+"/"+@model.equipment+"/"+command
      message =
        user: @model.user
        project: @model.project
        station: @model.station
        equipment: @model.equipment
        command: command
        phase: "executing"
        startTime: new Date()
        trigger: "script"
        operator: "system"
        parameters: value
      @service.publishToMqtt topic, message, {qos:2, retain: true}

    setUValue: (su, channel, value) ->
      topic = "sample-values/"+@mu+"/"+su+"/"+channel
      topic = "sample-values/"+@mu+"/scene" if channel is "scene"
      message =
        monitoringUnitId: @mu
        sampleUnitId: su
        channelId: channel
        value: value
        timestamp: new Date()
      @service.publishToMqtt topic, message, {qos: 0, retain: true}

    splitColor: (color)->
      if color is @COLOR.auto
        ret =
          r: -1
          g: -1
          b: -1
      else if color?.split('-').length is 3
        ret =
          r: parseInt color.split('-')[0]
          g: parseInt color.split('-')[1]
          b: parseInt color.split('-')[2]
      else
        ret = @splitColor @COLOR.whiteflash
      ret

    switchToSpaceMode: ->
      uleds = {}
      for n in [1..@height]
        uleds[n] = {key: "u-"+n, value: @LED.idle}
        if @uwei[n]?.illegaluprack
          uleds[n].value = @LED.illegaluprack
        else if @uwei[n]?.illegaldownrack
          uleds[n].value = @LED.illegaldownrack
        else if @uwei[n]?.planStatus?.message?.parameters[0]?.value is 1
          uleds[n].value = @LED.planuprack
        else if @uwei[n]?.planStatus?.message?.parameters[0]?.value is 2
          uleds[n].value = @LED.plandownrack
        else if @uwei[n]?.server
          uleds[n].value = @LED.uprack
      leds = _.values uleds
      @setLeds leds

    switchToCapacityMode: (mode)->
      getModeColor = (mod)=>
        ret = @COLOR.white
        switch mod
          when "space" then ret = @COLOR.green
          when "power" then ret = @COLOR.red
          when "cooling" then ret = @COLOR.blue
          when "weight" then ret = @COLOR.cyan
          when "planspace" then ret = @COLOR.greenflash
          when "planpower" then ret = @COLOR.redflash
          when "plancooling" then ret = @COLOR.blueflash
          when "planweight" then ret = @COLOR.cyanflash
        ret

      value = @data?["ratio-"+mode] ? 0
      planvalue = @data?["plan-ratio-"+mode] ? 0
      ucount = @data?["ucount"] ? @height ? 42
      assetcount = parseInt ucount*value/100
      plancount = parseInt ucount*planvalue/100
      leds = []
      leds.push {key: "u-"+i, value: getModeColor mode} for i in [1..assetcount] if 1<=assetcount
      leds.push {key: "u-"+j, value: getModeColor "plan"+mode} for j in [(assetcount+1)..(assetcount+plancount)] if assetcount+1<=assetcount+plancount
      leds.push {key: "u-"+l, value: getModeColor "blank"} for l in [(assetcount+plancount+1)..ucount] if assetcount+plancount+1<=ucount

      @setLeds leds

    switchToHeatmapMode: ->
      getTemperatureColor = (uwei)=>
        ret = @COLOR.green
        value = @data?["u-"+uwei+"-server-temperature"]
        if (value-@NORMALTEMPERATURE)>=3
          ret = @COLOR.red
        else if (value-@NORMALTEMPERATURE)>=1 and (value-@NORMALTEMPERATURE)<3
          ret = @COLOR.yellow
        else if (@NORMALTEMPERATURE-value)>=1 and (@NORMALTEMPERATURE-value)<3
          ret = @COLOR.cyan
        else if (@NORMALTEMPERATURE-value)>=3 and value?
          ret = @COLOR.blue
        ret

      ucount = @data?["ucount"] ? @height ? 42
      leds = []
      leds.push {key: "u-"+i, value: getTemperatureColor i} for i in [1..ucount]

      @setLeds leds

    switchToLedMode: (mode)->
      ucount = @data?["ucount"] ? @height ? 42
      leds = []
      leds.push {key: "u-"+i, value: @COLOR[mode]} for i in [1..ucount]

      @setLeds leds

    setLeds: (leds) ->
      for led in leds
        @setUValue led.key, "led", led.value if !@udirection
        @setUValue "u-"+(43-parseInt(led.key.split("-")[1])), "led", led.value if @udirection

      if @hasULocator
        for led in leds
          led.value = @splitColor led.value
          led.key = "u-"+(43-parseInt(led.key.split("-")[1])) if @udirection
        @setULedColor "set-u-leds", leds

    updateServer: (server) ->
      uwei = _.find server.properties, (pro)->pro.id is "row"
      return if not uwei?.value
      srv = new Server.Server server, @service, @
      srv.getInfo()
      @uwei[uwei.value] ?= {}
      @uwei[uwei.value].server = srv

    dispose: ->
      @signalSubscription?.dispose()
      @commandSubscription?.dispose()
      @eventSubscription?.dispose()
      @subject?.dispose()
      @sceneSubject?.dispose()
      super

  exports =
    Rack: Rack