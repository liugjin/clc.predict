###
* File: predict-service
* User: Pu
* Date: 2018/9/1
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web', 'iced-coffee-script'], (base, iced) ->
  iced = iced.iced if iced.iced

  class PredictService extends base.RpcService
    constructor: (options) ->
      super options

    initializeProcedures: ->
      @registerProcedure ['echo']

    # you can define any methods for rpc
    echo: (options,callback) ->
      time = options.parameters.time + " -- server: #{new Date().toISOString()}"
      result =
        time: time

      callback? null, result


  exports =
    PredictService: PredictService
