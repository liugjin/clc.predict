// Generated by IcedCoffeeScript 108.0.13

/*
* File: equipment-signals-directive
* User: David
* Date: 2019/05/26
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var EquipmentSignalsDirective, exports;
  EquipmentSignalsDirective = (function(_super) {
    __extends(EquipmentSignalsDirective, _super);

    function EquipmentSignalsDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "equipment-signals";
      EquipmentSignalsDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EquipmentSignalsDirective.prototype.setScope = function() {};

    EquipmentSignalsDirective.prototype.setCSS = function() {
      return css;
    };

    EquipmentSignalsDirective.prototype.setTemplate = function() {
      return view;
    };

    EquipmentSignalsDirective.prototype.show = function(scope, element, attrs) {
      if (!scope.equipment) {
        return this.getEquipment(scope, "_station_management", (function(_this) {
          return function() {
            return _this.getEquipmentSignals(scope, scope.equipment);
          };
        })(this));
      }
    };

    EquipmentSignalsDirective.prototype.getEquipmentSignals = function(scope, equipment) {
      return equipment != null ? equipment.loadProperties(null, (function(_this) {
        return function(err, pts) {
          var properties;
          console.log("properties:", pts);
          properties = equipment.getPropertyValue("_focus", ["communication-status", "alarms", "equipments", "alarmSeverity"]);
          return equipment != null ? equipment.loadSignals(null, function(err, signals) {
            var _ref;
            scope.signals = _.filter(signals, function(sig) {
              var _ref;
              return _ref = sig.model.signal, __indexOf.call(properties, _ref) >= 0;
            });
            if ((_ref = scope.esubscription) != null) {
              _ref.dispose();
            }
            return scope.esubscription = _this.commonService.subscribeEquipmentSignalValues(scope.equipment);
          }) : void 0;
        };
      })(this)) : void 0;
    };

    EquipmentSignalsDirective.prototype.resize = function(scope) {};

    EquipmentSignalsDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.esubscription) != null ? _ref.dispose() : void 0;
    };

    return EquipmentSignalsDirective;

  })(base.BaseDirective);
  return exports = {
    EquipmentSignalsDirective: EquipmentSignalsDirective
  };
});
