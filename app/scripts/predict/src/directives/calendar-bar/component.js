// Generated by IcedCoffeeScript 108.0.13

/*
* File: calendar-bar-directive
* User: David
* Date: 2020/01/08
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], function(base, css, view, _, moment, echart) {
  var CalendarBarDirective, exports;
  CalendarBarDirective = (function(_super) {
    __extends(CalendarBarDirective, _super);

    function CalendarBarDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "calendar-bar";
      CalendarBarDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    CalendarBarDirective.prototype.setScope = function() {};

    CalendarBarDirective.prototype.setCSS = function() {
      return css;
    };

    CalendarBarDirective.prototype.setTemplate = function() {
      return view;
    };

    CalendarBarDirective.prototype.show = function(scope, element, attrs) {
      var option, update;
      option = {
        color: ["#3b99ff", "#174c90", "transparent"],
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        series: [
          {
            name: '',
            type: 'pie',
            clockwise: false,
            radius: ['60%', '80%'],
            avoidLabelOverlap: false,
            label: {
              position: 'inner',
              color: "white"
            },
            data: []
          }, {
            name: '',
            type: 'pie',
            radius: '40%',
            label: {
              normal: {
                show: true,
                position: 'center',
                rich: {
                  title: {
                    color: '#8d9fbe',
                    fontSize: 14
                  },
                  value: {
                    color: 'white',
                    fontSize: 14
                  }
                }
              }
            },
            labelLine: {
              show: false
            },
            data: [
              {
                name: "总量",
                value: 0
              }
            ]
          }
        ]
      };
      scope.chart = echart.init(element.find(".calendar-bar")[0]);
      scope.chart.on("click", (function(_this) {
        return function(e) {
          return _this.commonService.publishEventBus("orderType", e);
        };
      })(this));
      update = (function(_this) {
        return function(param) {
          var sum;
          sum = 0;
          _.each(param.data, function(d) {
            return sum += d.value;
          });
          option.series[0].data = param.data;
          option.series[1].label.normal.formatter = function(d) {
            return '{title|' + d.seriesName + '}\n\n{value|' + sum + '}';
          };
          option.series[1].data[0].value = sum;
          scope.chart.setOption(option);
          return scope.$applyAsync();
        };
      })(this);
      return scope.$watch("parameters", (function(_this) {
        return function(param) {
          var series;
          if (!param) {
            return;
          }
          series = option.series[0];
          if (series.name !== param.title) {
            option.series[0].name = param.title;
            option.series[1].name = param.title;
          }
          if (series.data.length === 0) {
            return update(param);
          } else if (param.data[0].value !== series.data[0].value || param.data[1].value !== series.data[1].value) {
            return update(param);
          }
        };
      })(this));
    };

    CalendarBarDirective.prototype.resize = function(scope) {
      return scope.chart.resize();
    };

    CalendarBarDirective.prototype.dispose = function(scope) {};

    return CalendarBarDirective;

  })(base.BaseDirective);
  return exports = {
    CalendarBarDirective: CalendarBarDirective
  };
});
