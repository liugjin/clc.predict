# File: u-service
# User: david
# Date: 2018/3/28
# Desc:

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define [
  'clc.foundation',
  'clc.foundation.data/app/models/configuration/equipments-model',
  'clc.foundation.data/app/models/configuration/equipment-types-model',
  'clc.foundation.data/app/models/configuration/equipment-templates-model',
  'clc.foundation.data/app/models/configuration/equipment-properties-model',
  './model/rack'
  'underscore',
  '../../../index-setting.json'
], (base, equipment, type, template, property, Rack, _,setting) ->
  class UService extends base.MqttService
    constructor: (@options) ->
      super @options
      @equip = new equipment.EquipmentsModel
      @template = new template.EquipmentTemplatesModel
      @type = new type.EquipmentTypesModel
      @property = new property.EquipmentPropertiesModel
      @cache = {}
      @racks = {}
      @templates = {}
      @servers = {}

    initialize: (callback) ->
      super callback
      @getRacks()

    getRacks: ()->
      @equip.find {type:'rack'}, null, (err, models)=>
        return if err
        @type.find {base: 'IT'}, null, (err, types) =>
          @tps = _.uniq (_.pluck types, "type")
          @property.find {type: {$in:@tps}, property: {$in:['height','has-u-locator','u-direction','normal-temperature']}}, null, (err, properties) =>
            for property in properties
              key = property.user+"."+property.project+"."+property.type+"."+property.template+"."+property.property
              @cache[key] = {property: property.value}
            @template.find {type: {$in:@tps}}, null, (err, templates) =>
              for template in templates
                @templates[template.user+"."+template.project+"."+template.type+"."+template.template] = template.user+"."+template.project+"."+template.base if template.base

              for model in models
                rack = new Rack.Rack(model, @)
      #          rack.start()
                rackId = rack.model.user+"."+rack.model.project+"."+rack.model.station+"."+rack.model.equipment
                @racks[rackId] = rack

              setTimeout =>
                console.log "begin to subscribe rack info"
                @subscribeRackSignal "scene"
                @subscribeRackSignal "ratio-space"
                @subscribeRackSignal "ratio-power"
                @subscribeRackSignal "ratio-cooling"
                @subscribeRackSignal "ratio-weight"
                @subscribeRackSignal "plan-ratio-space"
                @subscribeRackSignal "plan-ratio-power"
                @subscribeRackSignal "plan-ratio-cooling"
                @subscribeRackSignal "plan-ratio-weight"
                @subscribeRackSignal "ucount"
                @subscribeRackSignal "u-[n]-server-temperature", 42
                @subscribeRackSignal "u-[n]-asset", 42
                @subscribeRackCommand "set-u-plan-[n]", 42
                @subscribeRackCommand "set-u-[n]-led", 42
                @subscribeRackCommand "toggle-scene"
                @subscribeRackEvent "illegal-up-rack-[n]", 42
                @subscribeRackEvent "illegal-down-rack-[n]", 42

                @subscribeRackULocatorChange()
              , 10000

    getEquipmentProperty: (equip, property, callback) ->
      pty = _.find equip.properties, (pt)->pt.id is property
      return callback? pty.value if pty
      key = equip.user+"."+equip.project+"."+equip.type+"."+equip.template+"."+property
      @getTemplateProperties key, (value)=>
        callback? value

    getTemplateProperties: (key, callback) ->
      if @cache[key]?.property
        callback @cache[key].property
      else if @cache[key]?.base
        @getTemplateProperties @cache[key].base, callback
      else
        user = key.split('.')[0]
        project = key.split('.')[1]
        type = key.split('.')[2]
        template = key.split('.')[3]
        property = key.split(".")[4]
        @getBaseTemplateProperties user, project, type, template, property, callback

    getBaseTemplateProperties: (user, project, type, template, property, callback) ->
      key = @templates[user+"."+project+"."+type+"."+template]
      if not key
        callback? null
      else
        @getTemplateProperties key+"."+property, callback
#      key = user+ "."+project+"."+type+"."+template+"."+property
#      @property.findOne {user: user, project: project, type: type, template: template, property: property}, null, (err, pty) =>
#        return callback? null if err
#        if pty
#          @cache[key] = {property: pty.value}
#          callback? pty.value
#        else
#          @template.findOne {user: user, project: project, type: type, template: template}, null, (err, model)=>
#            return callback? null if err or not model?.base
#            @cache[key] ={base: model.user+"."+model.project+"."+model.base+"."+property}
#            @getTemplateProperties @cache[key].base, callback

    subscribeRackSignal: (signal, count = 1)->
      for i in [1..count]
        topic = "signal-values/+/+/+/+/"+signal.replace "[n]", i
        @subscribeToMqtt topic, {qos: 0}, (data) =>
          return if data.message.equipmentType isnt "rack"
          rackId = data.message.user+"."+data.message.project+"."+data.message.station+"."+data.message.equipment
          @racks[rackId]?.setSignal data

    subscribeRackCommand: (command, count = 1)->
      for i in [1..count]
        topic = "command-values/+/+/+/+/"+command.replace "[n]", i
        @subscribeToMqtt topic, {qos: 0}, (data) =>
          return if not data.message or data.message.phase isnt "executing" or not data.message._phase
          rackId = data.message.user+"."+data.message.project+"."+data.message.station+"."+data.message.equipment
          @racks[rackId]?.setCommand data

    subscribeRackEvent: (event, count = 1)->
      for i in [1..count]
        topic = "event-values/+/+/+/+/"+event.replace "[n]", i
        @subscribeToMqtt topic, {qos: 0}, (data) =>
          return if data.message.equipmentType isnt "rack"
          rackId = data.message.user+"."+data.message.project+"."+data.message.station+"."+data.message.equipment
          @racks[rackId]?.setEvent data

    subscribeRackULocatorChange: ->
      topic = "configuration/equipment/#"
      @subscribeToMqtt topic, {qos:0}, (data)=>
        if not _.isEmpty data.message.parent
          rackId = data.message.user+"."+data.message.project+"."+data.message.station+"."+data.message.parent
          if @racks.hasOwnProperty rackId
            @racks[rackId].updateServer data.message
            console.log "update server:", data.message
        else if data.message.type is "rack"
          rackId = data.message.user+"."+data.message.project+"."+data.message.station+"."+data.message.equipment
          @racks[rackId]?.dispose()
          if data.topic.indexOf("create")>0 or data.topic.indexOf("update")>0
            rack = new Rack.Rack(data.message, @)
  #          rack.start()
            key = rack.model.user+"."+rack.model.project+"."+rack.model.station+"."+rack.model.equipment
            @racks[key] = rack
        else if data.message.type in @tps
          id = data.message.user+"."+data.message.project+"."+data.message.station+"."+data.message.equipment
          @servers[id].removeFromRack @servers[id].rack if @servers[id]?.rack
      , false

  exports =
    UService: UService
