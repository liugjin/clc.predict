// Generated by IcedCoffeeScript 108.0.13

/*
* File: forecast-results-list-directive
* User: David
* Date: 2020/02/12
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var ForecastResultsListDirective, exports;
  ForecastResultsListDirective = (function(_super) {
    __extends(ForecastResultsListDirective, _super);

    function ForecastResultsListDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.processEvent = __bind(this.processEvent, this);
      this.subscribeValues = __bind(this.subscribeValues, this);
      this.setData = __bind(this.setData, this);
      this.show = __bind(this.show, this);
      this.id = "forecast-results-list";
      ForecastResultsListDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ForecastResultsListDirective.prototype.setScope = function() {};

    ForecastResultsListDirective.prototype.setCSS = function() {
      return css;
    };

    ForecastResultsListDirective.prototype.setTemplate = function() {
      return view;
    };

    ForecastResultsListDirective.prototype.show = function(scope, element, attrs) {
      this.setData(scope);
      scope.inverterImg = this.getComponentPath('images/inverter.svg');
      scope.motorImg = this.getComponentPath('images/motor.svg');
      scope.switchboxImg = this.getComponentPath('images/switch-box.svg');
      scope.transformerImg = this.getComponentPath('images/transformer.svg');
      return scope.typeImages = {};
    };

    ForecastResultsListDirective.prototype.setData = function(scope) {
      scope.events = {};
      scope.eventsArray = [];
      scope.eventSubscriptionArray = [];
      scope.eventsArray.splice(0, scope.eventsArray.length);
      return this.subscribeValues(scope);
    };

    ForecastResultsListDirective.prototype.subscribeValues = function(scope) {
      var eventSubscription, filter;
      filter = {
        user: scope.project.model.user,
        project: scope.project.model.project,
        station: scope.station.model.station
      };
      eventSubscription = this.commonService.eventLiveSession.subscribeValues(filter, (function(_this) {
        return function(err, msg) {
          if (err) {
            return console.log(err);
          }
          return _this.processEvent(scope, msg);
        };
      })(this));
      return scope.eventSubscriptionArray.push(eventSubscription);
    };

    ForecastResultsListDirective.prototype.processEvent = function(scope, data) {
      var event, k, key, message, v;
      if (!data) {
        return;
      }
      message = data.message;
      switch (message.equipmentType) {
        case 'inverter':
          message.typeImg = scope.inverterImg;
          break;
        case 'motor':
          message.typeImg = scope.motorImg;
          break;
        case 'switch-box':
          message.typeImg = scope.switchboxImg;
          break;
        case 'transformer':
          message.typeImg = scope.transformerImg;
      }
      key = "" + message.user + "." + message.project + "." + message.station + "." + message.equipment + "." + message.event + "." + message.severity + "." + message.startTime;
      if (scope.events.hasOwnProperty(key)) {
        event = scope.events[key];
        for (k in message) {
          v = message[k];
          event[k] = v;
        }
      } else {
        event = angular.copy(message);
        scope.events[key] = event;
        if (event.eventType === "divine" && event.phase === "start") {
          scope.eventsArray.unshift(event);
        }
      }
      return scope.clickEvent = (function(_this) {
        return function(event) {
          return window.location.hash = "#/device-details/" + event.user + "/" + event.project + "/" + event.station + "/" + event.equipment;
        };
      })(this);
    };

    ForecastResultsListDirective.prototype.resize = function(scope) {};

    ForecastResultsListDirective.prototype.dispose = function(scope) {
      return scope.eventSubscriptionArray.forEach((function(_this) {
        return function(sub) {
          return sub.dispose();
        };
      })(this));
    };

    return ForecastResultsListDirective;

  })(base.BaseDirective);
  return exports = {
    ForecastResultsListDirective: ForecastResultsListDirective
  };
});
