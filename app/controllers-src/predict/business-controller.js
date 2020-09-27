// Generated by IcedCoffeeScript 108.0.13
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.web', 'clc.foundation', 'clc.foundation.data/app/models/configuration/equipments-model', 'clc.foundation.data/app/models/monitoring/signal-values-model', 'clc.foundation.data/app/models/monitoring/command-values-model', 'clc.foundation.data/app/models/system/configurations-model', '../../services/predict/service-manager', '../../../index-setting.json', 'moment/moment', 'underscore'], function(web, service, equipment, signal, command, configurations, sm, setting, moment, _) {
  var BusinessController, exports;
  BusinessController = (function(_super) {
    __extends(BusinessController, _super);

    function BusinessController() {
      var options;
      BusinessController.__super__.constructor.apply(this, arguments);
      this.equip = new equipment.EquipmentsModel;
      this.signal = new signal.SignalValuesModel;
      this.command = new command.CommandValuesModel;
      this.configurations = new configurations.ConfigurationsModel;
      options = {};
      options.setting = sm.getService("register").getSetting();
      options.configurationService = sm.getService("configuration");
      options.mqtt = setting.mqtt;
      this.mqttService = new service.MqttService(setting);
      this.mqttService.start();
    }

    BusinessController.prototype.tokenCheck = function(token, callback) {
      console.log(token);
      return this.roleService.getTokenRole(token, {
        user: setting.myproject.user,
        project: setting.myproject.project
      }, (function(_this) {
        return function(err, data) {
          if (err) {
            return _this.renderData(err, {
              result: 0
            });
          }
          return typeof callback === "function" ? callback() : void 0;
        };
      })(this));
    };

    BusinessController.prototype.renderData = function(err, data) {
      if (data == null) {
        data = {};
      }
      if (err) {
        data._err = err;
      }
      return this.res.json(data);
    };

    BusinessController.prototype.getConfigurationInfo = function() {
      var endTime, params, startTime;
      params = this.req.query;
      startTime = params.startTime;
      endTime = params.endTime;
      return this.configurations.query({
        updatetime: {
          "$gte": startTime,
          "$lt": endTime
        }
      }, null, (function(_this) {
        return function(err, datas) {
          if (err) {
            console.log(err);
          }
          if (datas.length) {
            return _this.renderData(null, {
              result: 1,
              data: datas
            });
          } else {
            return _this.renderData('无数据', {
              result: 0
            });
          }
        };
      })(this));
    };

    BusinessController.prototype.manualControl = function() {
      var message1, message2, params, topic1, topic2;
      params = this.req.body;
      console.log(params);
      topic1 = "ssv/" + params.su + "/" + params.channel1;
      topic2 = "ssv/" + params.su + "/" + params.channel2;
      message1 = params.channel1data;
      message2 = params.channel2data;
      console.log(topic1);
      console.log(message1);
      if (topic1 && message1) {
        console.log('发布消息topic1');
        this.mqttService.publishToMqtt(topic1, message1);
      }
      if (topic2 && message2) {
        console.log('发布消息topic2');
        this.mqttService.publishToMqtt(topic2, message2);
      }
      return this.renderData(null, {
        result: 1
      });
    };

    return BusinessController;

  })(web.AuthController);
  return exports = {
    BusinessController: BusinessController
  };
});
