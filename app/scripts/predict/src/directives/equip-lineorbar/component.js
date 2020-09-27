// Generated by IcedCoffeeScript 108.0.13

/*
* File: equip-lineorbar-directive
* User: David
* Date: 2019/05/16
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var EquipLineorbarDirective, exports;
  EquipLineorbarDirective = (function(_super) {
    __extends(EquipLineorbarDirective, _super);

    function EquipLineorbarDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "equip-lineorbar";
      EquipLineorbarDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EquipLineorbarDirective.prototype.setScope = function() {};

    EquipLineorbarDirective.prototype.setCSS = function() {
      return css;
    };

    EquipLineorbarDirective.prototype.setTemplate = function() {
      return view;
    };

    EquipLineorbarDirective.prototype.show = function(scope, element, attrs) {
      var cleanData, currentEquip, currentSignal, currentStation, currentTime, dictToName, getHistoryData, getNewData, getTodayData, severityType, subscribeTodayValue, _ref;
      scope.chartValues = [];
      currentEquip = null;
      currentStation = null;
      dictToName = {};
      scope.currentSignalName = "信号选择";
      if (!scope.mode) {
        scope.mode = "now";
      }
      currentTime = "";
      currentSignal = [];
      scope.signalList = [];
      subscribeTodayValue = null;
      severityType = {};
      _.map(scope.project.dictionary.eventseverities.items, (function(_this) {
        return function(d) {
          return severityType[d.model.severity] = d.model.color;
        };
      })(this));
      scope.tipFun = (function(_this) {
        return function(params, ticket, callback) {
          var html;
          html = "<div>" + params[0].name + "</div>";
          _.map(params, function(d) {
            var color, _obj;
            _obj = _.find(scope.chartValues, function(m) {
              return m.key === d.name && m.category === d.seriesName;
            });
            if (_obj) {
              if (severityType[_obj != null ? _obj.severity : void 0]) {
                color = severityType[_obj != null ? _obj.severity : void 0];
              } else {
                color = 'green';
              }
              if (_obj.severity === 0) {
                return html += "<div><div style='margin-top:5px;margin-right:3px;float: left;height: 12px;width: 12px;border-radius: 50%;background-color:green;'></div>" + (_obj != null ? _obj.category : void 0) + ":" + _obj.value + "</div>";
              } else {
                return html += "<div><div style='margin-top:5px;margin-right:3px;float: left;height: 12px;width: 12px;border-radius: 50%;background-color:" + color + "'></div>" + (_obj != null ? _obj.category : void 0) + ":" + _obj.value + "</div>";
              }
            }
          });
          return html;
        };
      })(this);
      scope.selectSignal = (function(_this) {
        return function(signal, index) {
          var sigId;
          sigId = _.indexOf(currentSignal, signal.signal);
          if (sigId === -1 && currentSignal.length < 3) {
            currentSignal.push(signal.signal);
          } else if (sigId !== -1 && currentSignal.length > 1) {
            currentSignal = _.filter(currentSignal, function(d) {
              return d !== signal.signal;
            });
          } else {
            _this.display('请选择1-3个信号!');
            return;
          }
          scope.signalList[index].check = !signal.check;
          if (scope.mode === "now") {
            return getTodayData();
          } else {
            return getHistoryData();
          }
        };
      })(this);
      cleanData = (function(_this) {
        return function() {
          scope.chartValues = [];
          return scope.signalList = [];
        };
      })(this);
      getNewData = (function(_this) {
        return function(equipment) {
          if (subscribeTodayValue) {
            subscribeTodayValue.dispose();
          }
          return subscribeTodayValue = _this.commonService.subscribeEquipmentSignalValues(equipment, function(d) {
            if (scope.mode === "now") {
              _.map(scope.signalList, function(m) {
                if (d.model.signal === m.signal) {
                  return scope.chartValues.push({
                    name: m.signal,
                    key: moment(d.data.timestamp).format("HH:mm"),
                    value: d.data.value,
                    type: 'line',
                    category: dictToName[m.signal]
                  }, {
                    severity: d.data.severity
                  });
                }
              });
              return scope.chartValues = _.sortBy(scope.chartValues, 'key');
            }
          });
        };
      })(this);
      getTodayData = (function(_this) {
        return function() {
          var filter;
          filter = scope.project.getIds();
          filter.station = scope.equipment.model.station;
          filter.equipment = scope.equipment.model.equipment;
          filter.signal = {
            $in: currentSignal
          };
          filter.startTime = moment().format("YYYY-MM-DD 00:00:00");
          filter.endTime = moment().format("YYYY-MM-DD 23:59:59");
          return _this.commonService.reportingService.querySignalRecords({
            filter: filter,
            fileds: null,
            paging: null,
            sorting: null
          }, function(err, records) {
            if (!records) {
              return console.warn(err.toString());
            }
            scope.chartValues = _.map(records, function(d) {
              return {
                name: d.signal,
                key: moment(d.timestamp).format("HH:mm"),
                value: d.value,
                type: 'line',
                category: dictToName[d.signal],
                severity: d.severity
              };
            });
            scope.chartValues = _.sortBy(scope.chartValues, 'key');
            return window.setTimeout(function() {
              getNewData(currentEquip);
              return 500;
            });
          });
        };
      })(this);
      getHistoryData = (function(_this) {
        return function(message) {
          var filter, mode, newSignalsArr, time;
          mode = scope.mode;
          time = currentTime;
          if (message) {
            mode = message.type;
            time = message.time;
            currentTime = message.time;
          }
          filter = scope.project.getIds();
          filter.station = scope.equipment.model.station;
          filter.equipment = scope.equipment.model.equipment;
          filter.signal = {
            $in: currentSignal
          };
          newSignalsArr = [];
          if (mode === "day") {
            filter.period = {
              $gte: time + " 00:00:00",
              $lt: time + " 23:59:59"
            };
          } else if (mode === "week") {
            filter.period = {
              $gte: moment().year(time.slice(0, 4)).week(time.slice(6, time.length - 1)).isoWeekday(1).format("YYYY-MM-DD"),
              $lt: moment().year(time.slice(0, 4)).week(time.slice(6, time.length - 1)).isoWeekday(7).format("YYYY-MM-DD")
            };
          } else if (mode === "month") {
            filter.period = {
              $gte: moment(time, "YYYY-MM").startOf('month'),
              $lt: moment(time, "YYYY-MM").endOf('month')
            };
          }
          return _this.commonService.reportingService.querySignalStatistics({
            filter: filter,
            fileds: null,
            paging: null,
            sorting: null
          }, function(err, statistic) {
            var aaa, i, j, result, sig, sum, _chartValues, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _n, _o, _ref, _results, _results1;
            if (typeof statistic === "object") {
              _chartValues = [];
              result = _.map(statistic, function(d) {
                return d;
              });
              console.log(result);
              if (result.length === 0) {
                result = _.map(currentSignal, function(d) {
                  return {
                    signal: d,
                    values: []
                  };
                });
              }
              if (result.length < currentSignal.length) {
                for (_i = 0, _len = result.length; _i < _len; _i++) {
                  i = result[_i];
                  newSignalsArr.push(i.signal);
                }
                for (_j = 0, _len1 = currentSignal.length; _j < _len1; _j++) {
                  j = currentSignal[_j];
                  if (__indexOf.call(newSignalsArr, j) < 0) {
                    result.push({
                      signal: j,
                      values: []
                    });
                  }
                }
              }
              if (mode === "day") {
                for (_k = 0, _len2 = result.length; _k < _len2; _k++) {
                  sig = result[_k];
                  _chartValues = _chartValues.concat(_.map((function() {
                    _results = [];
                    for (_l = 1; _l <= 24; _l++){ _results.push(_l); }
                    return _results;
                  }).apply(this), function(d) {
                    var hour, _obj;
                    hour = d < 10 ? "0" + d : d.toString();
                    _obj = _.find(sig.values, function(m) {
                      return moment(m.timestamp).format("HH") === hour && m.mode === "hour";
                    });
                    if (_obj) {
                      return {
                        name: sig.signal,
                        type: "line",
                        category: dictToName[sig.signal],
                        key: hour + "时",
                        value: _obj.value,
                        severity: _obj.severity
                      };
                    }
                    return {
                      name: sig.signal,
                      type: "line",
                      category: dictToName[sig.signal],
                      key: hour + "时",
                      value: 0,
                      severity: 0
                    };
                  }));
                }
              } else if (mode === "week") {
                for (_m = 0, _len3 = result.length; _m < _len3; _m++) {
                  sig = result[_m];
                  _chartValues = _chartValues.concat(_.map(["周一", "周二", "周三", "周四", "周五", "周六", "周日"], function(d, i) {
                    var day, _obj;
                    day = moment().year(time.slice(0, 4)).week(time.slice(6, time.length - 1)).isoWeekday(i + 1).format("YYYY-MM-DD");
                    _obj = _.find(sig.values, function(m) {
                      return m.period === day && m.mode === "day";
                    });
                    if (_obj) {
                      return {
                        index: i,
                        name: sig.signal,
                        type: "line",
                        category: dictToName[sig.signal],
                        key: d,
                        value: _obj.value,
                        severity: _obj.severity
                      };
                    }
                    return {
                      index: i,
                      name: sig.signal,
                      type: "line",
                      category: dictToName[sig.signal],
                      key: d,
                      value: 0,
                      severity: 0
                    };
                  }));
                }
              } else if (mode === "month") {
                for (_n = 0, _len4 = result.length; _n < _len4; _n++) {
                  sig = result[_n];
                  _chartValues = _chartValues.concat(_.map((function() {
                    _results1 = [];
                    for (var _o = 1, _ref = moment(time, "YYYY-MM").endOf('month').format("DD"); 1 <= _ref ? _o <= _ref : _o >= _ref; 1 <= _ref ? _o++ : _o--){ _results1.push(_o); }
                    return _results1;
                  }).apply(this), function(d, i) {
                    var day, today, _obj;
                    day = d < 10 ? "0" + d : d.toString();
                    today = time + "-" + day;
                    _obj = _.find(sig.values, function(m) {
                      return m.period === today && m.mode === "day";
                    });
                    if (_obj) {
                      return {
                        name: sig.signal,
                        type: "line",
                        category: dictToName[sig.signal],
                        key: day,
                        value: _obj.value,
                        severity: _obj.severity
                      };
                    }
                    return {
                      name: sig.signal,
                      type: "line",
                      category: dictToName[sig.signal],
                      key: day,
                      value: 0,
                      severity: 0
                    };
                  }));
                }
              }
              aaa = _.sortBy(_chartValues, function(item) {
                return item.index;
              });
              console.log(aaa);
              sum = 0;
              return scope.chartValues = aaa;
            } else {
              return cleanData();
            }
          });
        };
      })(this);
      if ((_ref = scope.timeSubscribe) != null) {
        _ref.dispose();
      }
      scope.timeSubscribe = this.commonService.subscribeEventBus("equipment-time", (function(_this) {
        return function(msg) {
          var _ref1, _ref2;
          scope.mode = (_ref1 = msg.message) != null ? _ref1.type : void 0;
          if (((_ref2 = msg.message) != null ? _ref2.type : void 0) === "now") {
            return getTodayData();
          } else {
            return getHistoryData(msg.message);
          }
        };
      })(this));
      return scope.equipment.loadSignals(null, (function(_this) {
        return function(err, signallists) {
          var item, newSignalLists, signals, _i, _len;
          signals = _.find(scope.equipment.properties.items, function(d) {
            return d.model.property === "_signals";
          });
          newSignalLists = [];
          for (_i = 0, _len = signallists.length; _i < _len; _i++) {
            item = signallists[_i];
            if (item.model.dataType === 'string' || item.model.dataType === 'json') {

            } else {
              newSignalLists.push(item);
            }
          }
          if (signals && signals.value) {
            scope.signalList = _.map(JSON.parse(signals.value), function(d, i) {
              var _signal;
              _signal = _.find(newSignalLists, function(m) {
                return m.model.signal === d.signal;
              });
              return {
                signal: d.signal,
                name: _signal != null ? _signal.model.name : void 0,
                check: i === 0 ? true : false
              };
            });
          } else {
            scope.signalList = _.map(newSignalLists, function(d, i) {
              return {
                signal: d.model.signal,
                name: d.model.name,
                check: i === 0 ? true : false
              };
            });
          }
          currentSignal = [scope.signalList[0].signal];
          _.map(scope.signalList, function(d) {
            return dictToName[d.signal] = d.name;
          });
          if (scope.mode === "now") {
            return getTodayData();
          } else {
            return getHistoryData();
          }
        };
      })(this), true);
    };

    EquipLineorbarDirective.prototype.resize = function(scope) {};

    EquipLineorbarDirective.prototype.dispose = function(scope) {
      var _ref, _ref1, _ref2;
      if ((_ref = scope.timeSubscribe) != null) {
        _ref.dispose();
      }
      if ((_ref1 = scope.treeSubscribe) != null) {
        _ref1.dispose();
      }
      return (_ref2 = scope.subSignal) != null ? _ref2.dispose() : void 0;
    };

    return EquipLineorbarDirective;

  })(base.BaseDirective);
  return exports = {
    EquipLineorbarDirective: EquipLineorbarDirective
  };
});
