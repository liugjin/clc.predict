// Generated by IcedCoffeeScript 108.0.13

/*
* File: room-3d-component-directive
* User: David
* Date: 2019/02/20
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'lodash', "moment", "./room"], function(base, css, view, _, moment, Room) {
  var Scene3dComponentDirective, exports;
  Scene3dComponentDirective = (function(_super) {
    __extends(Scene3dComponentDirective, _super);

    function Scene3dComponentDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.getDeviceSignal = __bind(this.getDeviceSignal, this);
      this.changeMaterial = __bind(this.changeMaterial, this);
      this.rotateRoom = __bind(this.rotateRoom, this);
      this.subscribeSignal = __bind(this.subscribeSignal, this);
      this.show = __bind(this.show, this);
      this.id = "scene-3d-component";
      Scene3dComponentDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    Scene3dComponentDirective.prototype.setScope = function() {};

    Scene3dComponentDirective.prototype.setCSS = function() {
      return css;
    };

    Scene3dComponentDirective.prototype.setTemplate = function() {
      return view;
    };

    Scene3dComponentDirective.prototype.show = function(scope, element, attrs) {
      var room, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
      console.log("设备", scope.equipment);
      console.log("站点", scope.station);
      scope.showDevice = false;
      scope.equipSubscription = {};
      room = new Room("room-1", element.find('.room-3d-canvas')[0], {
        camera: {
          type: ((_ref = scope.parameters.camera) != null ? _ref.type : void 0) || "PerspectiveCamera",
          fov: ((_ref1 = scope.parameters.camera) != null ? _ref1.fov : void 0) || 50,
          x: ((_ref2 = scope.parameters.camera) != null ? _ref2.x : void 0) || 0,
          y: ((_ref3 = scope.parameters.camera) != null ? _ref3.y : void 0) || 0,
          z: ((_ref4 = scope.parameters.camera) != null ? _ref4.z : void 0) || 0,
          rotationX: ((_ref5 = scope.parameters.camera) != null ? _ref5.rotationX : void 0) || 0,
          rotationY: ((_ref6 = scope.parameters.camera) != null ? _ref6.rotationY : void 0) || 0,
          rotationZ: ((_ref7 = scope.parameters.camera) != null ? _ref7.rotationZ : void 0) || 0
        },
        renderder: {
          alpha: true,
          antialias: true
        },
        orbitControl: true
      });
      scope.room = room;
      scope.updateIconsStyle = (function(_this) {
        return function(reflesh) {
          var coordinate, left, thing, top, _i, _j, _len, _len1, _ref10, _ref11, _ref8, _ref9, _results;
          if (scope.updateIconsFlag || reflesh) {
            if (((_ref8 = scope.iconThings) != null ? _ref8.length : void 0) > 0) {
              _ref9 = scope.iconThings;
              for (_i = 0, _len = _ref9.length; _i < _len; _i++) {
                thing = _ref9[_i];
                coordinate = room.getScreenCoordinate(thing.showingObject);
                thing.iconStyle = {};
                thing.iconStyle["width"] = scope.iconSize + 'px';
                thing.iconStyle["height"] = scope.iconSize + 'px';
                left = Number((coordinate.x - room.offsetLeft - scope.iconSize / 2).toFixed(0));
                top = (coordinate.y - room.offsetTop - scope.iconSize / 2).toFixed(0);
                thing.iconStyle["left"] = left + 'px';
                thing.iconStyle["top"] = top + 'px';
              }
            }
            if (((_ref10 = scope.dataBoxThings) != null ? _ref10.length : void 0) > 0) {
              _ref11 = scope.dataBoxThings;
              _results = [];
              for (_j = 0, _len1 = _ref11.length; _j < _len1; _j++) {
                thing = _ref11[_j];
                coordinate = room.getScreenCoordinate(thing.showingObject);
                thing.dataBoxStyle = {};
                left = Number((coordinate.x - room.offsetLeft).toFixed(0));
                top = (coordinate.y - room.offsetTop).toFixed(0);
                thing.dataBoxStyle["left"] = left + 'px';
                _results.push(thing.dataBoxStyle["top"] = top + 'px');
              }
              return _results;
            }
          }
        };
      })(this);
      scope.$watch('parameters.scene', (function(_this) {
        return function(scene) {
          var preloadCallback, _ref8, _ref9;
          if (!scene) {
            return;
          }
          preloadCallback = function(preloadValue) {
            return scope.preloadValue = preloadValue;
          };
          scope.sceneLoadedCompleted = false;
          _this.rotateRoom(scope, false);
          return room.loadScene(scene, function() {
            scope.sceneLoadedCompleted = true;
            console.log("3D文件加载完了订阅信号");
            _this.subscribeSignal(scope);
            return _this.getDeviceSignal(scope, scope.equipment, 'alarm-status');
          }, preloadCallback, {
            noCache: (_ref8 = scope.parameters) != null ? (_ref9 = _ref8.options) != null ? _ref9.noCache : void 0 : void 0
          });
        };
      })(this));
      return scope.$watch('parameters.stationId', function(stationId) {
        if (!stationId) {
          return;
        }
        return console.log(stationId);
      });
    };

    Scene3dComponentDirective.prototype.subscribeSignal = function(scope) {
      this.commonService.subscribeEventBus('rotate', (function(_this) {
        return function(msg) {
          if (msg && msg.message) {
            console.log("订阅信号", msg);
            return _this.rotateRoom(scope, !scope.flag);
          }
        };
      })(this));
      this.commonService.subscribeEventBus('showDevice', (function(_this) {
        return function(msg) {
          if (msg && msg.message) {
            console.log("订阅信号", msg);
            return _this.changeMaterial(scope, !scope.showDevice);
          }
        };
      })(this));
      return this.commonService.subscribeEventBus('default', (function(_this) {
        return function(msg) {
          if (msg && msg.message) {
            console.log("订阅信号", msg);
            return _this.changeMaterial(scope, false);
          }
        };
      })(this));
    };

    Scene3dComponentDirective.prototype.rotateRoom = function(scope, flag) {
      scope.flag = flag;
      scope.room.autoRotate(flag, 1);
      if (flag) {
        return scope.room.addAnimate('rotateRoom', (function(_this) {
          return function() {
            return scope.updateIconsStyle(true);
          };
        })(this));
      } else {
        return scope.room.removeAnimate('rotateRoom');
      }
    };

    Scene3dComponentDirective.prototype.changeMaterial = function(scope, flag) {
      scope.showDevice = flag;
      return scope.room.changeMaterial(flag);
    };

    Scene3dComponentDirective.prototype.getDeviceSignal = function(scope, equipments, signalID) {
      var filter, str, _ref;
      filter = {
        user: scope.project.model.user,
        project: scope.project.model.project,
        station: scope.station.model.station,
        equipment: '+',
        signal: signalID
      };
      str = scope.station.key + "-" + signalID;
      if ((_ref = scope.equipSubscription[str]) != null) {
        _ref.dispose();
      }
      return scope.equipSubscription[str] = this.commonService.signalLiveSession.subscribeValues(filter, (function(_this) {
        return function(err, d) {
          console.log("信号", d);
          if (d && d.message) {
            return scope.room.generatorThings(d.message.equipment, d.message.value);
          }
        };
      })(this));
    };

    Scene3dComponentDirective.prototype.resize = function(scope) {};

    Scene3dComponentDirective.prototype.dispose = function(scope) {
      var _ref;
      if ((_ref = scope.room) != null) {
        _ref.dispose();
      }
      return _.map(scope.equipSubscription, (function(_this) {
        return function(value, key) {
          return value != null ? value.dispose() : void 0;
        };
      })(this));
    };

    return Scene3dComponentDirective;

  })(base.BaseDirective);
  return exports = {
    Scene3dComponentDirective: Scene3dComponentDirective
  };
});
