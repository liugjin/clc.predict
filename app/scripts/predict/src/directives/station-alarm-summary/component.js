// Generated by IcedCoffeeScript 108.0.13

/*
* File: station-alarm-summary-directive
* User: David
* Date: 2020/02/12
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var StationAlarmSummaryDirective, exports;
  StationAlarmSummaryDirective = (function(_super) {
    __extends(StationAlarmSummaryDirective, _super);

    function StationAlarmSummaryDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.addZero = __bind(this.addZero, this);
      this.setAlarmGrade = __bind(this.setAlarmGrade, this);
      this.processEvents = __bind(this.processEvents, this);
      this.subscribeEventLive = __bind(this.subscribeEventLive, this);
      this.setData = __bind(this.setData, this);
      this.show = __bind(this.show, this);
      this.id = "station-alarm-summary";
      StationAlarmSummaryDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    StationAlarmSummaryDirective.prototype.setScope = function() {};

    StationAlarmSummaryDirective.prototype.setCSS = function() {
      return css;
    };

    StationAlarmSummaryDirective.prototype.setTemplate = function() {
      return view;
    };

    StationAlarmSummaryDirective.prototype.show = function(scope, element, attrs) {
      return this.setData(scope);
    };

    StationAlarmSummaryDirective.prototype.setData = function(scope) {
      var subject, _ref, _ref1;
      scope.stationID = scope.station.model.station;
      scope.alarmDataArr = [];
      scope.alarms = {};
      scope.eventReal = {};
      scope.severities = (_ref = scope.project) != null ? (_ref1 = _ref.dictionary) != null ? _ref1.eventseverities.items : void 0 : void 0;
      scope.alarms[scope.stationID] = {
        count: 0,
        severity: 0,
        list: {},
        severities: {}
      };
      _.each(scope.severities, function(severity) {
        return scope.alarms[scope.stationID].severities[severity.model.severity] = 0;
      });
      subject = new Rx.Subject;
      this.subscribeEventLive(scope, subject);
      subject.debounce(100).subscribe((function(_this) {
        return function() {
          return _this.processEvents(scope);
        };
      })(this));
      return this.processEvents(scope);
    };

    StationAlarmSummaryDirective.prototype.subscribeEventLive = function(scope, subject) {
      var filter, _ref;
      filter = {
        user: scope.project.model.user,
        project: scope.project.model.project
      };
      if ((_ref = scope.eventSubscription) != null) {
        _ref.dispose();
      }
      return scope.eventSubscription = this.commonService.eventLiveSession.subscribeValues(filter, (function(_this) {
        return function(err, d) {
          var event, key, _ref1;
          if (!((_ref1 = d.message) != null ? _ref1.event : void 0) || !scope.alarms[d.message.station]) {
            return;
          }
          event = d.message;
          scope.eventReal = {
            equipmentName: event.equipmentName,
            eventName: event.eventName
          };
          key = "" + event.user + "." + event.project + "." + event.station + "." + event.equipment + "." + event.event + "." + event.severity + "." + event.startTime;
          scope.alarms[event.station].list[key] = event;
          if (event.phase === "completed") {
            delete scope.alarms[event.station].list[key];
          }
          return subject.onNext();
        };
      })(this));
    };

    StationAlarmSummaryDirective.prototype.processEvents = function(scope) {
      var currentStation, key, map, val, value, _ref, _ref1, _ref2, _ref3;
      _ref = scope.alarms;
      for (key in _ref) {
        value = _ref[key];
        _.each(scope.severities, function(severity) {
          return value.severities[severity] = 0;
        });
        value.count = (_.keys(value.list)).length;
        value.severity = (_ref1 = _.max(_.filter(_.values(value.list), function(item) {
          return !item.endTime;
        }), function(it) {
          return it.severity;
        })) != null ? _ref1.severity : void 0;
        map = _.countBy(_.values(value.list), function(item) {
          return item.severity;
        });
        for (key in map) {
          val = map[key];
          value.severities[key] = val;
        }
      }
      currentStation = scope.alarms[scope.stationID];
      currentStation.count === scope.alarms[scope.stationID].count;
      if (currentStation.severity < scope.alarms[scope.stationID].severity) {
        currentStation.severity = scope.alarms[scope.stationID].severity;
      }
      _ref2 = currentStation.severities;
      for (key in _ref2) {
        val = _ref2[key];
        currentStation.severities[key] === ((_ref3 = scope.alarms[scope.stationID].severities[key]) != null ? _ref3 : 0);
      }
      scope.$applyAsync();
      return this.setAlarmGrade(scope);
    };

    StationAlarmSummaryDirective.prototype.setAlarmGrade = function(scope) {
      var alarmData, grade, _i, _len, _ref;
      scope.alarmDataArr.splice(0, scope.alarmDataArr.length);
      _ref = scope.severities;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        grade = _ref[_i];
        alarmData = {
          alarmNum: 0,
          alarmName: "",
          severity: null,
          imgUrl: ""
        };
        alarmData.alarmNum = this.addZero(scope.alarms[scope.stationID].severities[grade.model.severity]);
        alarmData.alarmName = grade.model.name;
        alarmData.severity = grade.model.severity;
        alarmData.imgUrl = "" + (this.getComponentPath('images/alarm-' + grade.model.severity + ".svg"));
        scope.alarmDataArr.push(alarmData);
      }
      alarmData = {
        alarmNum: 0,
        alarmName: "",
        severity: null,
        imgUrl: ""
      };
      alarmData.alarmNum = this.addZero(scope.alarms[scope.stationID].count);
      alarmData.alarmName = "告警总数";
      alarmData.imgUrl = "" + (this.getComponentPath('images/total-alarm.svg'));
      return scope.alarmDataArr.unshift(alarmData);
    };

    StationAlarmSummaryDirective.prototype.addZero = function(num) {
      if (parseInt(num) < 10 && parseInt(num) > 0) {
        num = '0' + num;
      }
      return num;
    };

    StationAlarmSummaryDirective.prototype.resize = function(scope) {};

    StationAlarmSummaryDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.eventSubscription) != null ? _ref.dispose() : void 0;
    };

    return StationAlarmSummaryDirective;

  })(base.BaseDirective);
  return exports = {
    StationAlarmSummaryDirective: StationAlarmSummaryDirective
  };
});
