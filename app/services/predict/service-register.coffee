###
* File: service-register
* User: Pu
* Date: 2018/9/1
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation', 'clc.foundation.web', './predict-service'
], (base, web, cs) ->
  class ServiceRegister extends base.ServiceRegisterBase
    constructor: (options, namespace) ->
      super options, namespace

    createService: (name) ->
      switch name
        when 'register'
          service = new web.RegisterService @getOptions 'register'
        when 'configuration'
          service = new web.ConfigurationService @getOptions 'configuration'
        when 'home'
          service = new web.HomeService @options
        when 'predict'
          service = new cs.PredictService @getOptions('services')
        else
          throw "unsupported service: #{name}"

      service


  exports =
    ServiceRegister: ServiceRegister
