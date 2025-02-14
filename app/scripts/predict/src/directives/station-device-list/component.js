// Generated by IcedCoffeeScript 108.0.13

/*
* File: station-device-list-directive
* User: David
* Date: 2020/03/17
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var StationDeviceListDirective, exports;
  StationDeviceListDirective = (function(_super) {
    __extends(StationDeviceListDirective, _super);

    function StationDeviceListDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "station-device-list";
      StationDeviceListDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    StationDeviceListDirective.prototype.setScope = function() {};

    StationDeviceListDirective.prototype.setCSS = function() {
      return css;
    };

    StationDeviceListDirective.prototype.setTemplate = function() {
      return view;
    };

    StationDeviceListDirective.prototype.show = function(scope, element, attrs) {};

    StationDeviceListDirective.prototype.resize = function(scope) {};

    StationDeviceListDirective.prototype.dispose = function(scope) {};

    return StationDeviceListDirective;

  })(base.BaseDirective);
  return exports = {
    StationDeviceListDirective: StationDeviceListDirective
  };
});
