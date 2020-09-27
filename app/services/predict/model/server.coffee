`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['underscore'], (_) ->
  class Server
    constructor: (@model, @service, @rack) ->
      id = @model.user+"."+@model.project+"."+@model.station+"."+@model.equipment
      @service.servers[id] = @

    getInfo: (callback)->
      @service.getEquipmentProperty @model, "row", (val)=>
        @row = val
      @service.getEquipmentProperty @model, "height", (val)=>
        @height = val
        @lrow = if @row>@height then @row-@height+1 else 1

        callback? @

    removeFromRack: (rack)->
      return if @model.parent isnt rack.model.equipment
      @model.parent = ""
      @service.equip.save @model, (err, model) =>
        @publishAssetUpdate model
        @rack = null
      for row in [@row..@lrow]
        rack.uwei[row]?.server = null

    addToRack: (rack, row) ->
      @model.parent = rack.model.equipment
      uwei = _.findWhere @model.properties, {id:"row"}
      if uwei
        uwei.value = row
      else
        @model.properties.push {id:'row', value: row}
      @service.equip.save @model, (err, model)=>
        @publishAssetUpdate @model, if @model._id then "update" else "create"
      @getInfo (server) =>
        console.log "getInfo:", @row, @lrow
        for row in [@row..@lrow]
          if rack.uwei[row]
            rack.uwei[row].server = @
          else
            rack.uwei[row] = {server: @}


    publishAssetUpdate: (asset, type="update")->
      console.log "publish configuration:", asset
      topic = "configuration/equipment/"+type+"/"+asset.user+"/"+asset.project+"/"+asset.station+"/"+asset.equipment
      @service.publishToMqtt topic, asset, {qos:0, retain:false}

    dispose: ->
      @model = null

  exports =
    Server: Server