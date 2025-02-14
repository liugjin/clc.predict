// Generated by IcedCoffeeScript 108.0.13

/*
* File: event-statistic-directive
* User: David
* Date: 2018/11/26
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var EventStatisticDirective, exports;
  EventStatisticDirective = (function(_super) {
    __extends(EventStatisticDirective, _super);

    function EventStatisticDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "event-statistic";
      EventStatisticDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EventStatisticDirective.prototype.setScope = function() {
      return {
        stationId: '=',
        statisticValue: '='
      };
    };

    EventStatisticDirective.prototype.setCSS = function() {
      return css;
    };

    EventStatisticDirective.prototype.setTemplate = function() {
      return view;
    };

    EventStatisticDirective.prototype.show = function(scope, element, attrs) {
      scope.selectEventType = (function(_this) {
        return function(type) {
          scope.eventType = type;
          return _this.commonService.publishEventBus('event-list-eventType', type != null ? type.key : void 0);
        };
      })(this);
      return scope.$watch("parameters.stationId", (function(_this) {
        return function(stationId) {
          if (!stationId) {
            return;
          }
          return _this.getStation(scope, stationId);
        };
      })(this));
    };

    EventStatisticDirective.prototype.resize = function(scope) {};

    EventStatisticDirective.prototype.dispose = function(scope) {};

    return EventStatisticDirective;

  })(base.BaseDirective);
  return exports = {
    EventStatisticDirective: EventStatisticDirective
  };
});
