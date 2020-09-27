# sheen 2017-10-10
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web', 'clc.foundation',
  'clc.foundation.data/app/models/configuration/equipments-model',
  'clc.foundation.data/app/models/monitoring/signal-values-model',
  'clc.foundation.data/app/models/monitoring/command-values-model',
  'clc.foundation.data/app/models/system/configurations-model',
#  'clc.foundataion.web/app/src/role-model-service'
  '../../services/predict/service-manager',
  '../../../index-setting.json',
  'moment/moment','underscore'], (web, service, equipment, signal, command,configurations, sm, setting, moment, _) ->
  class BusinessController extends web.AuthController
    constructor: ->
      super
      @equip = new equipment.EquipmentsModel
      @signal = new signal.SignalValuesModel
      @command = new command.CommandValuesModel
      @configurations = new configurations.ConfigurationsModel
#      @roleService = sm.getService 'role'
      options = {}
      options.setting = sm.getService("register").getSetting()
      options.configurationService = sm.getService "configuration"
      options.mqtt = setting.mqtt
#      @roleService = new web.RoleModelService options
#      @roleService.start()
      @mqttService = new service.MqttService setting
      @mqttService.start()
#      @plog = service.utility
#      @plog.setLogger("/log/interface.log")

    tokenCheck:(token, callback)->
      console.log token
      @roleService.getTokenRole token,{user:setting.myproject.user,project:setting.myproject.project},(err,data)=>
#        console.log data
        return @renderData err,{result:0} if err
        callback?()

    renderData: (err, data) ->
      data ?= {}
      data._err = err if err
      @res.json data

    getConfigurationInfo: ->
      params = @req.query
#      console.log params
#      @plog.log "调获取configurations数据库表接口"
#      @tokenCheck params.token, =>
      startTime = params.startTime
      endTime = params.endTime
      @configurations.query {updatetime:{"$gte":startTime,"$lt":endTime}},null,(err,datas)=>
#      @configurations.query {type:params.type,action:params.action,timestamp:{"$gte":params.startTime,"$lt":params.endTime}},null,(err,equipments)=>
        console.log err if err
        if datas.length
          return @renderData null,{result:1,data:datas}
        else @renderData '无数据',{result:0}

    manualControl: ->
      params = @req.body
      console.log params
      # 接收参数 su 修改预测结果通道 channel1  预测结果值channel1data  编辑修改信息文本通道 channel2  编辑信息内容channel2data(这个数据为一个json对象)
      topic1 = "ssv/" + params.su + "/" + params.channel1
      topic2 = "ssv/" + params.su + "/" + params.channel2
      message1 = params.channel1data
      message2 = params.channel2data
      console.log topic1
      console.log message1
      if topic1 and message1
        console.log '发布消息topic1'
        @mqttService.publishToMqtt topic1,message1
      if topic2 and message2
        console.log '发布消息topic2'
        @mqttService.publishToMqtt topic2,message2
      @renderData null,{result:1}

  exports =
    BusinessController: BusinessController
