// Generated by IcedCoffeeScript 108.0.13

/*
* File: equipment-air-directive
* User: David
* Date: 2019/12/04
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var EquipmentAirDirective, exports;
  EquipmentAirDirective = (function(_super) {
    __extends(EquipmentAirDirective, _super);

    function EquipmentAirDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "equipment-air";
      EquipmentAirDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EquipmentAirDirective.prototype.setScope = function() {};

    EquipmentAirDirective.prototype.setCSS = function() {
      return css;
    };

    EquipmentAirDirective.prototype.setTemplate = function() {
      return view;
    };

    EquipmentAirDirective.prototype.show = function(scope, element, attrs) {
      alert(123);
      scope.theAirStatu = {
        equipName: "",
        equipStatu: ""
      };
      scope.equipments = [];
      scope.colorChange = false;
      scope.stations = _.each(scope.project.stations.nitems, function(n) {
        return n.model.station;
      });
      return _.each(scope.stations, (function(_this) {
        return function(station) {
          return station != null ? station.loadEquipments({
            type: "aircondition"
          }, null, function(err, equips) {
            scope.equipments = equips;
            return scope.selectEquipment = function(equip) {
              var _ref;
              if ((_ref = scope.subscribeStation) != null) {
                _ref.dispose();
              }
              return scope.subscribeStation = _this.commonService.subscribeEquipmentSignalValues(equip, function(signal) {
                if (signal.model.signal === "communication-status") {
                  if (signal.data) {
                    scope.theAirStatu.equipStatu = signal.data.formatValue;
                    scope.theAirStatu.equipName = signal.equipment.model.name;
                    if (signal.data.value === 0) {
                      return scope.colorChange = false;
                    } else {
                      return scope.colorChange = true;
                    }
                  }
                } else {
                  scope.theAirStatu.equipStatu = "--";
                  scope.theAirStatu.equipName = "--";
                  return scope.colorChange = true;
                }
              });
            };
          }, true) : void 0;
        };
      })(this));
    };

    EquipmentAirDirective.prototype.resize = function(scope) {};

    EquipmentAirDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.subscribeStation) != null ? _ref.dispose() : void 0;
    };

    return EquipmentAirDirective;

  })(base.BaseDirective);
  return exports = {
    EquipmentAirDirective: EquipmentAirDirective
  };
});
