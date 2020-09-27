// Generated by IcedCoffeeScript 108.0.13

/*
* File: device-temperature-directive
* User: David
* Date: 2019/12/23
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var DeviceTemperatureDirective, exports;
  DeviceTemperatureDirective = (function(_super) {
    __extends(DeviceTemperatureDirective, _super);

    function DeviceTemperatureDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.getDeviceSpecialSignal = __bind(this.getDeviceSpecialSignal, this);
      this.countDays = __bind(this.countDays, this);
      this.show = __bind(this.show, this);
      this.id = "device-temperature";
      DeviceTemperatureDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    DeviceTemperatureDirective.prototype.setScope = function() {};

    DeviceTemperatureDirective.prototype.setCSS = function() {
      return css;
    };

    DeviceTemperatureDirective.prototype.setTemplate = function() {
      return view;
    };

    DeviceTemperatureDirective.prototype.show = function(scope, element, attrs) {
      scope.equipSubscription = {};
      scope.daysRunning = 0;
      scope.signalDataArr = [];
      scope.switchBoxSignals = [];
      this.countDays(scope);
      if (scope.equipment.model.type === 'motor') {
        scope.signalDataArr = [
          {
            stateName: '当前状态',
            setValue: '运行',
            unit: '',
            signalID: 'current-state'
          }, {
            stateName: '外部温度',
            setValue: 0,
            unit: '℃',
            signalID: 'abroad'
          }, {
            stateName: '外壳温度',
            setValue: 0,
            unit: '℃',
            signalID: 'shell'
          }, {
            stateName: '定子温度',
            setValue: 0,
            unit: '℃',
            signalID: 'iron-core'
          }, {
            stateName: '输出电流',
            setValue: 0,
            unit: 'A',
            signalID: 'electric-current'
          }, {
            stateName: '运行天数',
            setValue: scope.daysRunning,
            unit: '天',
            signalID: ''
          }
        ];
        this.getDeviceSpecialSignal(scope, scope.equipment, 'current-state');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'abroad');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'shell');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'iron-core');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'electric-current');
        return this.getDeviceSpecialSignal(scope, scope.equipment, 'rate');
      } else if (scope.equipment.model.type === 'inverter') {
        scope.signalDataArr = [
          {
            stateName: '当前状态',
            setValue: '运行',
            unit: '',
            signalID: 'current-state'
          }, {
            stateName: '外部温度',
            setValue: 0,
            unit: '℃',
            signalID: 'abroad'
          }, {
            stateName: '内部温度',
            setValue: 0,
            unit: '℃',
            signalID: 'within'
          }, {
            stateName: '散热器温度',
            setValue: 0,
            unit: '℃',
            signalID: 'radiator'
          }, {
            stateName: '输出电流',
            setValue: 0,
            unit: 'A',
            signalID: 'electric-current'
          }, {
            stateName: '输出频率',
            setValue: 0,
            unit: 'Hz',
            signalID: 'rate'
          }, {
            stateName: '运行天数',
            setValue: scope.daysRunning,
            unit: '天',
            signalID: ''
          }
        ];
        this.getDeviceSpecialSignal(scope, scope.equipment, 'current-state');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'abroad');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'within');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'radiator');
        this.getDeviceSpecialSignal(scope, scope.equipment, 'electric-current');
        return this.getDeviceSpecialSignal(scope, scope.equipment, 'rate');
      } else if (scope.equipment.model.type === 'transformer') {
        scope.signalDataArr = [
          {
            stateName: '当前状态',
            setValue: '运行',
            unit: '',
            signalID: 'current-state'
          }, {
            stateName: '运行天数',
            setValue: scope.daysRunning,
            unit: '天',
            signalID: ''
          }
        ];
        return this.getDeviceSpecialSignal(scope, scope.equipment, 'current-state');
      } else {
        scope.signalDataArr = [
          {
            stateName: '当前状态',
            setValue: '运行',
            unit: '',
            signalID: 'current-state'
          }, {
            stateName: '运行天数',
            setValue: scope.daysRunning,
            unit: '天',
            signalID: ''
          }
        ];
        return scope.equipment.loadSignals(null, (function(_this) {
          return function(err, signals) {
            var item, j, _i, _j, _len, _len1, _ref, _results;
            if (err) {

            } else {
              for (_i = 0, _len = signals.length; _i < _len; _i++) {
                item = signals[_i];
                if (item.model.group && item.model.group === 'box') {
                  scope.switchBoxSignals.push(item);
                }
              }
              _ref = scope.switchBoxSignals;
              _results = [];
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                j = _ref[_j];
                scope.signalDataArr.push({
                  stateName: j.model.name,
                  setValue: 0,
                  unit: j.model.definition,
                  signalID: j.model.signal
                });
                _results.push(_this.getDeviceSpecialSignal(scope, scope.equipment, j.model.signal));
              }
              return _results;
            }
          };
        })(this));
      }
    };

    DeviceTemperatureDirective.prototype.countDays = function(scope) {
      var item, lasttime, time, _i, _len, _ref;
      time = Date.parse(new Date());
      lasttime = Date.parse(scope.equipment.model.createtime);
      if (scope.equipment.model.properties.length > 0) {
        _ref = scope.equipment.model.properties;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item.id === 'production-time') {
            lasttime = Date.parse(item.value);
          }
        }
      }
      scope.daysRunning = parseInt((time - lasttime) / (1000 * 60 * 60 * 24));
      return console.log(scope.daysRunning);
    };

    DeviceTemperatureDirective.prototype.getDeviceSpecialSignal = function(scope, equipment, signalID) {
      var filter, str, _ref;
      filter = {
        user: scope.project.model.user,
        project: scope.project.model.project,
        station: equipment.model.station,
        equipment: equipment.model.equipment,
        signal: signalID
      };
      str = equipment.key + "-" + signalID;
      if ((_ref = scope.equipSubscription[str]) != null) {
        _ref.dispose();
      }
      return scope.equipSubscription[str] = this.commonService.signalLiveSession.subscribeValues(filter, (function(_this) {
        return function(err, signal) {
          var data, _i, _len, _ref1, _results;
          if (signal && signal.message) {
            _ref1 = scope.signalDataArr;
            _results = [];
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              data = _ref1[_i];
              if (signalID === data.signalID) {
                if (signalID === 'current-state') {
                  console.log(signal.message);
                  if (signal.message.value !== 0) {
                    _results.push(data.setValue = '运行');
                  } else {
                    _results.push(data.setValue = '停机');
                  }
                } else {
                  _results.push(data.setValue = signal.message.value.toFixed(2));
                }
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          }
        };
      })(this));
    };

    DeviceTemperatureDirective.prototype.resize = function(scope) {};

    DeviceTemperatureDirective.prototype.dispose = function(scope) {
      return _.map(scope.equipSubscription, (function(_this) {
        return function(value, key) {
          return value != null ? value.dispose() : void 0;
        };
      })(this));
    };

    return DeviceTemperatureDirective;

  })(base.BaseDirective);
  return exports = {
    DeviceTemperatureDirective: DeviceTemperatureDirective
  };
});
