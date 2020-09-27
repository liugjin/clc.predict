// Generated by IcedCoffeeScript 108.0.13

/*
* File: map-header-directive
* User: David
* Date: 2019/12/23
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var MapHeaderDirective, exports;
  MapHeaderDirective = (function(_super) {
    __extends(MapHeaderDirective, _super);

    function MapHeaderDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.ergodicSite = __bind(this.ergodicSite, this);
      this.show = __bind(this.show, this);
      this.id = "map-header";
      MapHeaderDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    MapHeaderDirective.prototype.setScope = function() {};

    MapHeaderDirective.prototype.setCSS = function() {
      return css;
    };

    MapHeaderDirective.prototype.setTemplate = function() {
      return view;
    };

    MapHeaderDirective.prototype.show = function(scope, element, attrs) {
      this.publishEventBus('menuState', {
        'menu': 'menu'
      });
      scope.domShow = false;
      scope.headerType = 'map';
      scope.$watch('parameters.headerType', (function(_this) {
        return function(headerType) {
          if (headerType === 'map') {
            scope.headerType = 'map';
            scope.focus = "china";
            scope.centerName = null;
            scope.stations = [];
            scope.project.loadStations(null, function(err, stations) {
              scope.stations = stations;
              return _this.ergodicSite(scope);
            });
            _this.commonService.subscribeEventBus('map-china', function(msg) {
              if (msg && msg.message) {
                return scope.centerName = msg.message.data.model.name;
              }
            });
            _this.commonService.subscribeEventBus('map-asia', function(msg) {
              if (msg && msg.message) {
                return scope.centerName = msg.message.data.model.name;
              }
            });
          }
          if (headerType === 'scene') {
            scope.headerType = 'scene';
            scope.parentStation = scope.station.parentStation.model.name;
            scope.centerName = scope.station.model.name;
          }
          if (headerType === 'device') {
            scope.headerType = 'device';
          }
          if (headerType === 'device-info') {
            return scope.headerType = 'device-info';
          }
        };
      })(this));
      return scope.clickTime = (function(_this) {
        return function() {
          return scope.domShow = !scope.domShow;
        };
      })(this);
    };

    MapHeaderDirective.prototype.ergodicSite = function(scope) {
      var site, _i, _len, _ref, _results;
      _ref = scope.stations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        site = _ref[_i];
        if (site.model.station === scope.focus) {
          _results.push(scope.centerName = site.model.name);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    MapHeaderDirective.prototype.resize = function(scope) {};

    MapHeaderDirective.prototype.dispose = function(scope) {};

    return MapHeaderDirective;

  })(base.BaseDirective);
  return exports = {
    MapHeaderDirective: MapHeaderDirective
  };
});
