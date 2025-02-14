// Generated by IcedCoffeeScript 108.0.13

/*
* File: opc-curve-directive
* User: sheen
* Date: 2020/2/25
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts", 'rx', 'clc.foundation.angular/filters/format-string-filter'], function(base, css, view, _, moment, echarts, Rx, fsf) {
  var OpcCurveDirective, exports;
  OpcCurveDirective = (function(_super) {
    __extends(OpcCurveDirective, _super);

    function OpcCurveDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      OpcCurveDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.id = "opc-curve";
    }

    OpcCurveDirective.prototype.setScope = function() {};

    OpcCurveDirective.prototype.setCSS = function() {
      return css;
    };

    OpcCurveDirective.prototype.setTemplate = function() {
      return view;
    };

    OpcCurveDirective.prototype.show = function($scope, element, attrs) {
      var addPointToSerie, createOption, e, formatString, getLegend, getPeriod, getPoint, getPoints, getSeries, getSignals, getSingleProperty, maxPoints, option, querySignalRecords, queryStatisticRecords, renderChart, series, setSignalData, waitingLayout, _ref;
      if ((_ref = $scope.myChart) != null) {
        _ref.clear();
      }
      $scope.$root.loading = true;
      getPeriod = function(mode) {
        var endTime, startTime;
        if (mode == null) {
          mode = 'day';
        }
        switch (mode) {
          case 'now':
            startTime = moment().subtract(10, 'minutes');
            endTime = moment();
            break;
          default:
            startTime = moment().subtract(10, 'minutes');
            endTime = moment();
        }
        return $scope.period = {
          startTime: startTime,
          endTime: endTime,
          mode: mode
        };
      };
      formatString = fsf.FormatStringFilter();
      e = element.find('.ss-chart');
      $scope.mode = 'now';
      $scope.myChart = null;
      $scope.signals = [];
      $scope.selectSignals = [];
      option = null;
      series = [];
      maxPoints = 20;
      $scope.period = getPeriod($scope.mode);
      $scope.formatStartTime = moment($scope.period.startTime).format('YYYY-MM-DD');
      $scope.opcSignalSubscription = {};
      $scope.subCount = 0;
      $scope.rxSubscribe = null;
      waitingLayout = (function(_this) {
        return function($timeout, element, callback) {
          return $timeout(function() {
            if (element.width() <= 100) {
              return waitingLayout($timeout, element, callback);
            } else {
              return callback();
            }
          }, 200);
        };
      })(this);
      waitingLayout(this.$timeout, e, (function(_this) {
        return function() {
          return renderChart(e);
        };
      })(this));
      renderChart = (function(_this) {
        return function(element) {
          var _ref1;
          if ((_ref1 = $scope.myChart) != null) {
            _ref1.dispose();
          }
          $scope.myChart = null;
          return $scope.myChart = echarts.init(element[0]);
        };
      })(this);
      this.subscribeEventBus('stationId', (function(_this) {
        return function(d) {
          return _this.getStation($scope, d.message.stationId);
        };
      })(this));
      this.subscribeEventBus('equipmentId', (function(_this) {
        return function(d) {
          return _this.getEquipment($scope, d.message.equipmentId);
        };
      })(this));
      $scope.$watch('station', (function(_this) {
        return function(station) {
          if (!station) {

          }
        };
      })(this));
      $scope.$watch('equipment', (function(_this) {
        return function(equipment) {
          if (!equipment) {
            return;
          }
          return setTimeout(function() {
            return getSignals();
          }, 1000);
        };
      })(this));
      getSignals = (function(_this) {
        return function() {
          $scope.signals = [];
          $scope.selectSignals = [];
          return $scope.equipment.loadSignals(null, function(err, signals) {
            return getSingleProperty();
          });
        };
      })(this);
      getSingleProperty = (function(_this) {
        return function() {
          return _this.getProperty($scope, '_opcsignals', function() {
            if (!$scope.property) {
              return;
            }
            return setSignalData();
          }, true);
        };
      })(this);
      setSignalData = (function(_this) {
        return function() {
          var item, s, signals, _i, _len, _signals2;
          signals = [];
          _signals2 = JSON.parse($scope.property.value);
          for (_i = 0, _len = _signals2.length; _i < _len; _i++) {
            s = _signals2[_i];
            item = _.find($scope.equipment.signals.items, function(item) {
              return item.model.signal === s.signal;
            });
            if (item) {
              signals.push(item);
            }
          }
          $scope.signals = signals;
          if (!$scope.selectSignals.length) {
            $scope.selectSignals = _.filter($scope.signals, function(item) {
              var _ref1;
              return _ref1 = item.model.signal, __indexOf.call($scope.parameters.signalIds, _ref1) >= 0;
            });
          }
          return $scope.selectStatisticMode($scope.mode);
        };
      })(this);
      $scope.selectStatisticMode = (function(_this) {
        return function(mode, period) {
          $scope.mode = mode;
          $scope.period.mode = $scope.mode;
          return queryStatisticRecords($scope.selectSignals, $scope.mode, period, function(err, records) {
            var _ref1, _ref2;
            if ((_ref1 = $scope.myChart) != null) {
              _ref1.clear();
            }
            option = createOption(null, $scope.selectSignals, records);
            $scope.$root.loading = false;
            if ((_ref2 = $scope.myChart) != null) {
              _ref2.setOption(option, true);
            }
            return series = option.series;
          });
        };
      })(this);
      $scope.subscribeSignal = (function(_this) {
        return function(signal) {
          var _ref1;
          if ((_ref1 = $scope.opcSignalSubscription[signal.model.signal]) != null) {
            _ref1.dispose();
          }
          return $scope.opcSignalSubscription[signal.model.signal] = _this.commonService.subscribeSignalValue(signal, function(d) {
            var _ref2;
            $scope.subCount++;
            if ($scope.mode === 'now') {
              addPointToSerie(signal, d.data);
              return (_ref2 = $scope.myChart) != null ? _ref2.setOption({
                series: series
              }) : void 0;
            }
          });
        };
      })(this);
      addPointToSerie = (function(_this) {
        return function(signal, data) {
          var point, points, serie;
          serie = _.find(series, function(s) {
            return s.name === signal.model.name;
          });
          if (!serie) {
            return;
          }
          points = serie.data;
          point = getPoint(signal, data);
          if ($scope.subCount === 1 && (point.value[0] < points[7].value[0])) {
            return;
          }
          points.push(point);
          if (points.length > maxPoints) {
            points.shift();
          }
          return point;
        };
      })(this);
      querySignalRecords = (function(_this) {
        return function(signals, page, pageItems, sorting, mode, period, callback) {
          var filter, paging;
          if (page == null) {
            page = 1;
          }
          if (pageItems == null) {
            pageItems = 6;
          }
          if (sorting == null) {
            sorting = {
              'timestamp': 1
            };
          }
          if (!signals || (!signals.length)) {
            return;
          }
          filter = {
            startTime: $scope.period.startTime,
            endTime: $scope.period.endTime
          };
          paging = {
            page: page,
            pageItems: pageItems
          };
          return _this.commonService.querySignalsHistoryData(signals, filter.startTime, filter.endTime, function(err, records, pageInfo) {
            return typeof callback === "function" ? callback(err, records) : void 0;
          }, paging, sorting);
        };
      })(this);
      queryStatisticRecords = (function(_this) {
        return function(signals, mode, period, callback) {
          var observableBatch, _querySignalRecords, _ref1;
          if (mode == null) {
            mode = 'day';
          }
          if (!signals || (!signals.length)) {
            return;
          }
          if (mode === 'now') {
            _querySignalRecords = Rx.Observable.fromCallback(querySignalRecords);
            observableBatch = _.map(signals, function(s) {
              return _querySignalRecords([s], 1, 8, {
                timestamp: -1
              }, null, period);
            });
            if ((_ref1 = $scope.rxSubscribe) != null) {
              _ref1.dispose();
            }
            return $scope.rxSubscribe = Rx.Observable.forkJoin(observableBatch).subscribe(function(resArr) {
              var result, signal, _i, _len;
              result = {};
              _.each(resArr, function(item) {
                return _.extend(result, item[1]);
              });
              for (_i = 0, _len = signals.length; _i < _len; _i++) {
                signal = signals[_i];
                $scope.subscribeSignal(signal);
              }
              return typeof callback === "function" ? callback(null, result) : void 0;
            });
          }
        };
      })(this);
      getLegend = function(signals) {
        var legend, s, _i, _len;
        legend = [];
        for (_i = 0, _len = signals.length; _i < _len; _i++) {
          s = signals[_i];
          legend.push(s.model.name);
        }
        return legend;
      };
      getPoints = function(signal, values) {
        var point, points, value, _i, _len;
        points = [];
        for (_i = 0, _len = values.length; _i < _len; _i++) {
          value = values[_i];
          point = getPoint(signal, value);
          points.push(point);
        }
        points = _.sortBy(points, 'name');
        return points;
      };
      getPoint = function(signal, value) {
        var point, timestamp, tooltip;
        timestamp = moment(value.timestamp).format('HH:mm:ss');
        tooltip = "" + signal.model.name + ": " + (formatString(value.value, 'float', '0.[00]')) + "<br/>" + (moment(value.timestamp).format('YYYY-MM-DD HH:mm:ss'));
        point = {
          name: timestamp,
          value: [new Date(value.timestamp), value.value, tooltip]
        };
        return point;
      };
      getSeries = function(signals, values) {
        var k, points, sere, signal, v;
        if (!signals.length) {
          return;
        }
        series = [];
        for (k in values) {
          v = values[k];
          signal = _.find(signals, function(s) {
            return s.key === k;
          });
          points = getPoints(signal, v.values);
          sere = {
            name: signal != null ? signal.model.name : void 0,
            type: 'line',
            smooth: true,
            data: points
          };
          series.push(sere);
        }
        return series;
      };
      createOption = (function(_this) {
        return function(title, signals, values) {
          var legend;
          series = getSeries(signals, values);
          legend = getLegend(signals);
          option = {
            title: {
              text: $scope.parameters.title || '实时数据曲线',
              padding: [15, 10],
              textStyle: {
                color: '#EBEEF7',
                fontSize: 28
              },
              top: 28,
              left: 30
            },
            grid: {
              left: 40,
              top: 120,
              bottom: 60,
              right: 80,
              containLabel: true
            },
            tooltip: {
              trigger: 'axis',
              formatter: function(params) {
                var _ref1, _ref2, _ref3, _ref4;
                return (_ref1 = (_ref2 = params[0]) != null ? (_ref3 = _ref2.data) != null ? (_ref4 = _ref3.value) != null ? _ref4[2] : void 0 : void 0 : void 0) != null ? _ref1 : '';
              }
            },
            color: $scope.parameters.colors,
            legend: {
              top: 36,
              itemWidth: 45,
              itemHeight: 20,
              textStyle: {
                color: '#F4F7FF',
                fontSize: 18
              },
              data: legend
            },
            dataZoom: [
              {
                type: 'slider',
                textStyle: {
                  color: '#EBEEF7'
                },
                height: 18,
                start: 0,
                end: 100,
                bottom: 30
              }, {
                type: 'inside',
                start: 0,
                end: 100
              }
            ],
            xAxis: {
              type: 'time',
              axisLine: {
                show: false,
                lineStyle: {
                  color: '#b5c2d6'
                }
              },
              axisTick: {
                show: false
              },
              splitLine: {
                show: true,
                lineStyle: {
                  color: ['rgba(0,167,255,0.1)'],
                  width: 1
                }
              }
            },
            yAxis: {
              name: $scope.parameters.yname || "",
              max: $scope.parameters.ymax,
              min: $scope.parameters.ymin,
              type: 'value',
              axisLine: {
                show: false,
                lineStyle: {
                  color: '#b5c2d6'
                }
              },
              axisTick: {
                show: false
              },
              splitLine: {
                show: true,
                lineStyle: {
                  color: ['rgba(0,167,255,0.1)'],
                  width: 1
                }
              },
              axisLabel: {
                formatter: function(value, index) {
                  return value.toFixed(1);
                }
              }
            },
            series: series
          };
          return option;
        };
      })(this);
      $scope.resize = (function(_this) {
        return function() {
          return _this.$timeout(function() {
            var _ref1;
            return (_ref1 = $scope.myChart) != null ? _ref1.resize() : void 0;
          }, 100);
        };
      })(this);
      window.addEventListener('resize', $scope.resize);
      window.dispatchEvent(new Event('resize'));
      return this.$timeout((function(_this) {
        return function() {
          return window.dispatchEvent(new Event('resize'));
        };
      })(this), 1000);
    };

    OpcCurveDirective.prototype.resize = function($scope) {
      var _ref;
      return (_ref = $scope.myChart) != null ? _ref.resize() : void 0;
    };

    OpcCurveDirective.prototype.dispose = function($scope) {
      var _ref, _ref1;
      if ((_ref = $scope.myChart) != null) {
        _ref.dispose();
      }
      $scope.myChart = null;
      if ((_ref1 = $scope.rxSubscribe) != null) {
        _ref1.dispose();
      }
      return _.mapObject($scope.opcSignalSubscription, (function(_this) {
        return function(val) {
          return val != null ? val.dispose() : void 0;
        };
      })(this));
    };

    return OpcCurveDirective;

  })(base.BaseDirective);
  return exports = {
    OpcCurveDirective: OpcCurveDirective
  };
});
