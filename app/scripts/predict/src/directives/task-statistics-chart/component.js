// Generated by IcedCoffeeScript 108.0.13

/*
* File: task-statistics-chart-directive
* User: David
* Date: 2019/08/28
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], function(base, css, view, _, moment, echarts) {
  var TaskStatisticsChartDirective, exports;
  TaskStatisticsChartDirective = (function(_super) {
    __extends(TaskStatisticsChartDirective, _super);

    function TaskStatisticsChartDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "task-statistics-chart";
      TaskStatisticsChartDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    TaskStatisticsChartDirective.prototype.setScope = function() {};

    TaskStatisticsChartDirective.prototype.setCSS = function() {
      return css;
    };

    TaskStatisticsChartDirective.prototype.setTemplate = function() {
      return view;
    };

    TaskStatisticsChartDirective.prototype.show = function(scope, element, attrs) {
      var drawCharts, init;
      scope.ng = {
        myCharts: null
      };
      drawCharts = function() {
        var option;
        scope.ng.myCharts = echarts.init($(element).find('.my-charts')[0]);
        option = {
          title: {
            x: "47%",
            y: "45%",
            textAlign: "center",
            top: "70%",
            text: scope.parameters.name,
            textStyle: {
              fontWeight: "bold",
              color: "#ffffff",
              fontSize: 14
            }
          },
          series: [
            {
              name: "",
              type: "pie",
              center: ["50%", "45%"],
              radius: ["50%", "70%"],
              color: [scope.parameters.barColor, "transparent"],
              hoverAnimation: true,
              legendHoverLink: false,
              z: 10,
              labelLine: {
                normal: {
                  show: false
                }
              },
              data: [
                {
                  value: scope.parameters.value,
                  label: {
                    normal: {
                      formatter: scope.parameters.value.toString(),
                      position: "center",
                      show: true,
                      textStyle: {
                        fontSize: "24",
                        fontWeight: "normal",
                        color: "#fff"
                      }
                    }
                  }
                }, {
                  value: scope.parameters.total - scope.parameters.value
                }
              ]
            }, {
              name: "",
              type: "pie",
              center: ["50%", "45%"],
              radius: ["55%", "65%"],
              silent: true,
              labelLine: {
                normal: {
                  show: false
                }
              },
              z: 5,
              data: [
                {
                  value: 100,
                  itemStyle: {
                    color: "rgba(108,228,236,0.1)"
                  }
                }
              ]
            }
          ]
        };
        return scope.ng.myCharts.setOption(option);
      };
      init = (function(_this) {
        return function() {
          if (!scope.firstload) {
            return;
          }
          scope.ng.myCharts = echarts.init($(element).find('.my-charts')[0]);
          scope.ng.myCharts.on("click", function(e) {
            return _this.commonService.publishEventBus("orderType", scope.parameters.name);
          });
          return scope.$watch('parameters', function(data) {
            return drawCharts();
          });
        };
      })(this);
      return init();
    };

    TaskStatisticsChartDirective.prototype.resize = function(scope) {
      return scope.ng.myCharts.resize();
    };

    TaskStatisticsChartDirective.prototype.dispose = function(scope) {};

    return TaskStatisticsChartDirective;

  })(base.BaseDirective);
  return exports = {
    TaskStatisticsChartDirective: TaskStatisticsChartDirective
  };
});
