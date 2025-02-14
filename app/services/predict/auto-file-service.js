// Generated by IcedCoffeeScript 108.0.13
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation', 'clc.foundation.data/app/models/monitoring/event-values-model', 'clc.foundation.data/app/models/monitoring/signal-values-model', 'clc.foundation.data/app/models/monitoring/signal-values-last-model', 'clc.foundation.data/app/models/configuration/equipments-model', 'clc.foundation.data/app/models/configuration/stations-model', '../../../index-setting.json', 'moment', 'underscore'], function(base, event, signal, signallast, equipment, station, setting, moment, _) {
  var AutoFileService, exports;
  AutoFileService = (function(_super) {
    __extends(AutoFileService, _super);

    function AutoFileService(options) {
      this.options = options;
      this.downLoadCsv = __bind(this.downLoadCsv, this);
      this.querySignalValuesLast2 = __bind(this.querySignalValuesLast2, this);
      this.querySignalValueLast = __bind(this.querySignalValueLast, this);
      this.autoPullData = __bind(this.autoPullData, this);
      this.writeFile = __bind(this.writeFile, this);
      AutoFileService.__super__.constructor.call(this, this.options);
      this.event = new event.EventValuesModel;
      this.equip = new equipment.EquipmentsModel;
      this.station = new station.StationsModel;
      this.signal = new signal.SignalValuesModel;
      this.signalLast = new signallast.SignalValuesLastModel;
      this.fs = require("fs");
      this.path = require('path');
      this.request = require('request');
      this.equipSignalSubscribe = {};
    }

    AutoFileService.prototype.initialize = function(callback) {
      AutoFileService.__super__.initialize.call(this, callback);
      return this.writeFile();
    };

    AutoFileService.prototype.writeFile = function() {
      return this.equip.query({
        user: setting.myproject.user,
        project: setting.myproject.project
      }, null, (function(_this) {
        return function(err, equips) {
          var equip, _i, _len, _results;
          equips = _.filter(equips, function(item) {
            return item.group === 'enable';
          });
          _this.enableEquips = equips;
          _results = [];
          for (_i = 0, _len = equips.length; _i < _len; _i++) {
            equip = equips[_i];
            _results.push(_this.autoPullData(equip));
          }
          return _results;
        };
      })(this));
    };

    AutoFileService.prototype.autoPullData = function(equip) {
      var resources1, resources2, sig, topicKey, _i, _j, _len, _len1, _results;
      topicKey = "signal-values/" + equip.user + "/" + equip.project + "/" + equip.station + "/" + equip.equipment + "/";
      resources1 = ["s-data-1", "s-data-2", "s-data-3", "s-data-4", "s-data-opc"];
      resources2 = ["s-data-5", "s-data-6", "s-data-7"];
      for (_i = 0, _len = resources1.length; _i < _len; _i++) {
        sig = resources1[_i];
        this.querySignalValueLast(equip, sig);
      }
      _results = [];
      for (_j = 0, _len1 = resources2.length; _j < _len1; _j++) {
        sig = resources2[_j];
        _results.push(this.querySignalValuesLast2(equip, sig));
      }
      return _results;
    };

    AutoFileService.prototype.querySignalValueLast = function(equip, sigId) {
      return this.signalLast.query({
        user: setting.myproject.user,
        project: setting.myproject.project,
        station: equip.station,
        equipment: equip.equipment,
        signal: sigId
      }, null, (function(_this) {
        return function(err, signals) {
          var fileName, url;
          signal = signals[0];
          fileName = signal.station + "_" + signal.equipment + "_" + signal.signal + "_" + moment().format('YYYY-MM-DD-HH-mm-ss');
          url = signal.value;
          return _this.downLoadCsv(fileName, url);
        };
      })(this));
    };

    AutoFileService.prototype.querySignalValuesLast2 = function(equip, sigId) {
      return this.signalLast.query({
        user: setting.myproject.user,
        project: setting.myproject.project,
        station: equip.station,
        equipment: equip.equipment,
        signal: sigId
      }, null, (function(_this) {
        return function(err, signals) {
          var fileName, index, url, urls, _i, _len, _results;
          signal = signals[0];
          urls = signal.value.split(",");
          index = 0;
          _results = [];
          for (_i = 0, _len = urls.length; _i < _len; _i++) {
            url = urls[_i];
            index++;
            fileName = signal.station + "_" + signal.equipment + "_" + signal.signal + "_" + index + "_" + moment().format('YYYY-MM-DD-HH-mm-ss');
            _results.push(_this.downLoadCsv(fileName, url));
          }
          return _results;
        };
      })(this));
    };

    AutoFileService.prototype.downLoadCsv = function(filename, url) {
      console.log('要下载的文件地址为：' + url);
      return this.request(url).pipe(this.fs.createWriteStream(this.path.join('/predict', filename)));
    };

    return AutoFileService;

  })(base.MqttService);
  return exports = {
    AutoFileService: AutoFileService
  };
});
