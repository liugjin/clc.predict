// Generated by IcedCoffeeScript 108.0.13

/*
* File: three-quarter-pie-directive
* User: David
* Date: 2019/11/08
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], function(base, css, view, _, moment, echarts) {
  var ThreeQuarterPieDirective, exports;
  ThreeQuarterPieDirective = (function(_super) {
    __extends(ThreeQuarterPieDirective, _super);

    function ThreeQuarterPieDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "three-quarter-pie";
      ThreeQuarterPieDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ThreeQuarterPieDirective.prototype.setScope = function() {};

    ThreeQuarterPieDirective.prototype.setCSS = function() {
      return css;
    };

    ThreeQuarterPieDirective.prototype.setTemplate = function() {
      return view;
    };

    ThreeQuarterPieDirective.prototype.show = function(scope, element, attrs) {
      var drawCharts, init;
      drawCharts = (function(_this) {
        return function() {
          var option;
          option = {
            title: {
              text: scope.parameters.name || "没有设置",
              textStyle: {
                color: "#FFFFFF",
                fontWeight: 200,
                fontFamily: "PingFangSC-Regular",
                fontSize: 14
              },
              left: "center",
              top: "70%"
            },
            series: [
              {
                type: "pie",
                center: ["50%", "40%"],
                silent: true,
                radius: ["52%", "75%"],
                startAngle: 234,
                labelLine: {
                  normal: {
                    show: false
                  }
                },
                data: [
                  {
                    value: 4,
                    label: {
                      normal: {
                        formatter: scope.labelValue,
                        position: "center",
                        show: true,
                        textStyle: {
                          fontSize: 24,
                          fontWeight: "normal",
                          color: "#fff"
                        }
                      }
                    },
                    itemStyle: {
                      color: "rgba(108,228,236,0.1)"
                    }
                  }, {
                    value: 1,
                    itemStyle: {
                      color: "transparent"
                    }
                  }
                ]
              }, {
                center: ["50%", "40%"],
                type: "pie",
                startAngle: 234,
                radius: ["52%", "75%"],
                labelLine: {
                  normal: {
                    show: false
                  }
                },
                data: [
                  {
                    value: scope.value,
                    itemStyle: {
                      color: {
                        type: 'linear',
                        x: 0,
                        y: 0,
                        x2: 0,
                        y2: 1,
                        colorStops: [
                          {
                            offset: 0,
                            color: scope.parameters.startColor || "#3f3"
                          }, {
                            offset: 1,
                            color: scope.parameters.endColor || "#f33"
                          }
                        ],
                        global: false
                      }
                    }
                  }, {
                    value: scope.blankArea,
                    itemStyle: {
                      color: "transparent"
                    }
                  }
                ]
              }
            ]
          };
          scope.myChart.setOption(option);
          return scope.myChart.resize();
        };
      })(this);
      init = (function(_this) {
        return function() {
          if (!scope.firstload) {
            return;
          }
          scope.myChart = echarts.init($(element).find(".pie-charts")[0]);
          scope.blankArea = 1000;
          scope.total = 1000;
          scope.value = 0;
          scope.labelValue = "0";
          scope.$watch("parameters", function(msg) {
            var addBlankTotal, blankArea;
            scope.total = msg.total || 1000;
            scope.value = scope.parameters.value || 0;
            blankArea = Number((scope.total * 0.25).toFixed(2));
            addBlankTotal = blankArea + scope.total;
            scope.blankArea = addBlankTotal - scope.value;
            if (scope.parameters.showMode === "percent") {
              scope.labelValue = (Number(scope.value / scope.total) * 100).toFixed(0) + "%";
            } else {
              scope.labelValue = scope.value.toString() || "0";
            }
            return drawCharts();
          });
          return drawCharts();
        };
      })(this);
      return init();
    };

    ThreeQuarterPieDirective.prototype.resize = function(scope) {
      return scope.myChart.resize();
    };

    ThreeQuarterPieDirective.prototype.dispose = function(scope) {};

    return ThreeQuarterPieDirective;

  })(base.BaseDirective);
  return exports = {
    ThreeQuarterPieDirective: ThreeQuarterPieDirective
  };
});
