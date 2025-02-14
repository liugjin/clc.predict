// Generated by IcedCoffeeScript 108.0.11

/*
* File: device-3d-component-directive
* User: David
* Date: 2020/02/25
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "./room", "tween"], function(base, css, view, _, moment, Room, TWEEN) {
  var Device3dComponentDirective, exports;
  Device3dComponentDirective = (function(_super) {
    __extends(Device3dComponentDirective, _super);

    function Device3dComponentDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.resize = __bind(this.resize, this);
      this.getDeviceSpecialSignal = __bind(this.getDeviceSpecialSignal, this);
      this.getDeviceSignal = __bind(this.getDeviceSignal, this);
      this.rotateRoom = __bind(this.rotateRoom, this);
      this.subscribeSignal = __bind(this.subscribeSignal, this);
      this.sceneRoute = __bind(this.sceneRoute, this);
      this.show = __bind(this.show, this);
      this.id = "device-3d-component";
      Device3dComponentDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    Device3dComponentDirective.prototype.setScope = function() {};

    Device3dComponentDirective.prototype.setCSS = function() {
      return css;
    };

    Device3dComponentDirective.prototype.setTemplate = function() {
      return view;
    };

    Device3dComponentDirective.prototype.show = function(scope, element, attrs) {
      var loadSignalProperties, room;
      scope.equipmentType = scope.equipment.model.type;
      scope.equipSubscription = {};
      scope.eventSubscriptionArray = [];
      scope.events = {};
      scope.scene = '';
      scope.times = "";
      scope.subValueFlag = 1;
      scope.open = false;
      scope.label = {
        top: 960,
        left: 617,
        display: "none"
      };
      scope.preloadValue = 0;
      room = new Room(scope, $(element.find(".room-3d-canvas")[0]));
      scope.room = room;
      scope.$watch('parameters.scene', (function(_this) {
        return function(scene) {
          scope.scene = scene;
          if (!scene) {
            return;
          }
          loadSignalProperties();
          return _this.sceneRoute(scope);
        };
      })(this));
      scope.day = moment().format('YYYY-MM-DD');
      scope.time = moment().format('HH:mm:ss');
      scope.date = moment().format('dddd');
      clearInterval(scope.interval);
      scope.interval = setInterval((function(_this) {
        return function() {
          scope.day = moment().format('YYYY-MM-DD');
          scope.time = moment().format('HH:mm:ss');
          scope.date = moment().format('dddd');
          scope.$applyAsync();
          return scope.times = "" + scope.day + " " + scope.time;
        };
      })(this), 1000);
      scope.boxNone = (function(_this) {
        return function() {
          return scope.label.display = "none";
        };
      })(this);
      return loadSignalProperties = (function(_this) {
        return function() {
          var _ref;
          return (_ref = scope.equipment) != null ? _ref.loadProperties(null, function(err, properties) {
            var _ref1;
            scope.knowledge_base = JSON.parse(((_ref1 = scope.equipment.propertyValues) != null ? _ref1._knowledge_base : void 0) || '{}');
            return console.log(scope.knowledge_base);
          }) : void 0;
        };
      })(this);
    };

    Device3dComponentDirective.prototype.sceneRoute = function(scope) {
      var preloadCallback;
      scope.sceneLoadedCompleted = false;
      preloadCallback = (function(_this) {
        return function(preloadValue) {
          return scope.preloadValue = preloadValue;
        };
      })(this);
      return scope.room.loadSceneByUrl(scope.scene, (function(_this) {
        return function() {
          scope.sceneLoadedCompleted = true;
          _this.subscribeSignal(scope);
          return _this.getDeviceSignal(scope);
        };
      })(this), preloadCallback);
    };

    Device3dComponentDirective.prototype.subscribeSignal = function(scope) {
      var _ref, _ref1, _ref2;
      console.log("函数执行");
      if ((_ref = scope.stationEventBusRotate) != null) {
        _ref.dispose();
      }
      scope.stationEventBusRotate = this.commonService.subscribeEventBus('rotate', (function(_this) {
        return function(msg) {
          if (msg && msg.message) {
            scope.flag = !scope.flag;
            return scope.room.autoRotate(scope.flag, 1);
          }
        };
      })(this));
      if ((_ref1 = scope.stationEventBusBlast) != null) {
        _ref1.dispose();
      }
      scope.stationEventBusBlast = this.commonService.subscribeEventBus('unfoldMerger', (function(_this) {
        return function(msg) {
          if (msg && msg.message) {
            if (msg.message.data) {
              return scope.room.unpackAction();
            } else {
              return scope.room.packAction();
            }
          }
        };
      })(this));
      if ((_ref2 = scope.stationEventBusSelect) != null) {
        _ref2.dispose();
      }
      return scope.stationEventBusSelect = this.commonService.subscribeEventBus('select', (function(_this) {
        return function(msg) {
          if (msg && msg.message) {
            if (!scope.open) {
              scope.room.unpackAction();
            }
            return scope.room.selection(msg.message.data);
          }
        };
      })(this));
    };

    Device3dComponentDirective.prototype.rotateRoom = function(scope, flag) {
      scope.flag = flag;
      return scope.room.autoRotate(flag, 10);
    };

    Device3dComponentDirective.prototype.getDeviceSignal = function(scope) {
      return scope.equipment.loadSignals(null, (function(_this) {
        return function(err, signals) {
          var sig, _i, _len, _results;
          if (signals) {
            _results = [];
            for (_i = 0, _len = signals.length; _i < _len; _i++) {
              sig = signals[_i];
              if (sig.model.type === scope.equipment.model.type) {
                if (sig.model.template === "base-" + scope.equipment.model.type && sig.model.signal !== "device-flag") {
                  _results.push(_this.getDeviceSpecialSignal(scope, scope.equipment, sig));
                } else {
                  _results.push(void 0);
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

    Device3dComponentDirective.prototype.getDeviceSpecialSignal = function(scope, equipment, sig) {
      var currentSig, filter, signalID, str, _ref;
      signalID = sig.model.signal;
      filter = {
        user: scope.project.model.user,
        project: scope.project.model.project,
        station: equipment.model.station,
        equipment: equipment.model.equipment,
        signal: signalID
      };
      str = equipment.key + "-" + signalID;
      console.log('2222222222222');
      currentSig = {
        message: {
          signal: sig.model.signal,
          signalName: sig.model.name,
          signalState: '-',
          signalValue: 0,
          advice: '暂无',
          atime: '-'
        }
      };
      scope.room.generatorThings(currentSig, scope.open, null);
      if ((_ref = scope.equipSubscription[str]) != null) {
        _ref.dispose();
      }
      return scope.equipSubscription[str] = this.commonService.signalLiveSession.subscribeValues(filter, (function(_this) {
        return function(err, signal) {
          var currentAdvice;
          console.log('1111111111111111111');
          if (signal && signal.message) {
            if (sig.model.signal === signal.message.signal) {
              currentAdvice = scope.knowledge_base[sig.model.signal];
              console.log("currentAdvice", currentAdvice);
              signal.message.signalName = sig.model.name;
              signal.message.signalID = signal.message.signal;
              signal.message.atime = moment(signal.message.timestamp).format("YYYY-MM-DD HH:mm:ss");
              if (signal.message.value < 25) {
                signal.message.signalState = "优秀";
                signal.message.advice = currentAdvice.level1;
                scope.room.generatorThings(signal, scope.open, null);
              }
              if (signal.message.value >= 25 && signal.message.value < 50) {
                signal.message.signalState = "良好";
                signal.message.advice = currentAdvice.level2;
                scope.room.generatorThings(signal, scope.open, "#0094ff");
              }
              if (signal.message.value >= 50 && signal.message.value < 75) {
                signal.message.signalState = "一般";
                signal.message.advice = currentAdvice.level3;
                scope.room.generatorThings(signal, scope.open, "#F4D601");
              }
              if (signal.message.value >= 75) {
                signal.message.signalState = "极差";
                signal.message.advice = currentAdvice.level4;
                if (!scope.open) {
                  scope.room.unpackAction();
                  _this.commonService.publishEventBus("alarm-open", {
                    data: "open"
                  });
                }
                return scope.room.generatorThings(signal, scope.open, "#ff0045");
              }
            }
          }
        };
      })(this));
    };

    Device3dComponentDirective.prototype.resize = function(scope) {
      return scope.room.resize();
    };

    Device3dComponentDirective.prototype.dispose = function(scope) {
      var _ref, _ref1, _ref2;
      if ((_ref = scope.stationEventBusRotate) != null) {
        _ref.dispose();
      }
      if ((_ref1 = scope.stationEventBusBlast) != null) {
        _ref1.dispose();
      }
      if ((_ref2 = scope.stationEventBusSelect) != null) {
        _ref2.dispose();
      }
      clearInterval(scope.interval);
      return _.map(scope.equipSubscription, (function(_this) {
        return function(value, key) {
          return value != null ? value.dispose() : void 0;
        };
      })(this));
    };

    return Device3dComponentDirective;

  })(base.BaseDirective);
  return exports = {
    Device3dComponentDirective: Device3dComponentDirective
  };
});
