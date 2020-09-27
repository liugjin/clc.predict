// Generated by IcedCoffeeScript 108.0.13

/*
* File: order-situation-directive
* User: David
* Date: 2019/11/07
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var OrderSituationDirective, exports;
  OrderSituationDirective = (function(_super) {
    __extends(OrderSituationDirective, _super);

    function OrderSituationDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "order-situation";
      OrderSituationDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    OrderSituationDirective.prototype.setScope = function() {};

    OrderSituationDirective.prototype.setCSS = function() {
      return css;
    };

    OrderSituationDirective.prototype.setTemplate = function() {
      return view;
    };

    OrderSituationDirective.prototype.show = function(scope, element, attrs) {
      var clearData, getTypeOrderTotal, getUnfinishMonthCompletionData, init, processOrderData, subscribeOrderType, subscribeTasks;
      subscribeOrderType = (function(_this) {
        return function() {
          var _ref;
          if ((_ref = scope.subscribeOrderType) != null) {
            _ref.dispose();
          }
          return scope.subscribeOrderType = _this.commonService.subscribeEventBus("orderType", function(data) {
            scope.orderType = data.message;
            return processOrderData();
          });
        };
      })(this);
      subscribeTasks = (function(_this) {
        return function() {
          var topic, user, _ref;
          user = scope.$root.user.user;
          topic = "tasks/" + user + "/#";
          if ((_ref = scope.maintasksSubscri) != null) {
            _ref.dispose();
          }
          return scope.maintasksSubscri = _this.commonService.configurationLiveSession.subscribe(topic, function(err, order) {
            if (!order) {
              return;
            }
            return getTypeOrderTotal();
          });
        };
      })(this);
      clearData = (function(_this) {
        return function() {
          scope.typeOrderTotal = 0;
          scope.opsMonthFinish = 0;
          scope.opsMonthUnfinish = 0;
          scope.opsMonthOrder = 0;
          scope.opsUnfinish = 0;
          scope.secondPieChartCount = 0;
          scope.secondPieChartAllCount = 0;
          scope.thirdPieChartCount = 0;
          return scope.thirdPieChartAllCount = 0;
        };
      })(this);
      getUnfinishMonthCompletionData = (function(_this) {
        return function(order, monthStartTime, monthEndTime, orderCreateTime) {
          var lastNode, orderUpdateTime;
          lastNode = order.nodes.length - 1;
          orderUpdateTime = moment(order.updatetime).format('YYYY-MM-DD hh:mm:ss');
          scope.typeOrderTotal++;
          if (order.nodes[lastNode].state !== "approval") {
            scope.opsUnfinish++;
          }
          if (orderUpdateTime >= monthStartTime && orderUpdateTime <= monthEndTime) {
            scope.opsMonthOrder++;
            if (order.nodes[lastNode].state === "approval") {
              return scope.opsMonthFinish++;
            } else {
              return scope.opsMonthUnfinish++;
            }
          }
        };
      })(this);
      processOrderData = (function(_this) {
        return function() {
          var alarmEquipments, allContent, equipments, monthEndTime, monthStartTime;
          clearData();
          monthStartTime = moment().startOf('month').format('YYYY-MM-DD ') + "00:00:00";
          monthEndTime = moment().endOf('month').format('YYYY-MM-DD ') + "23:59:59";
          if (scope.orderType === "all") {
            scope.showMode = "count";
            scope.secondChartName = "本月设备作业台数";
            scope.threeCheartName = "本月发生异常台数";
            equipments = [];
            _.each(scope.opsOrder, function(order) {
              var contents, orderCreateTime, _ref, _ref1, _ref2;
              orderCreateTime = moment(order.createtime).format('YYYY-MM-DD HH:mm:ss');
              getUnfinishMonthCompletionData(order, monthStartTime, monthEndTime);
              contents = (_ref = JSON.parse(order != null ? (_ref1 = order.nodes[0]) != null ? (_ref2 = _ref1.contents[0]) != null ? _ref2.content : void 0 : void 0 : void 0)) != null ? _ref.content : void 0;
              return _.each(contents, function(content) {
                equipments = _.filter(equipments, function(equipment) {
                  return equipment.station !== content.station || equipment.equipment !== content.equipment;
                });
                equipments.push({
                  station: content.station,
                  equipment: content.equipment,
                  createtime: order.createtime
                });
                if (content.status === 1) {
                  scope.thirdPieChartAllCount++;
                  if (orderCreateTime >= monthStartTime) {
                    return scope.thirdPieChartCount++;
                  }
                }
              });
            });
            return _.each(equipments, function(equipment) {
              scope.secondPieChartAllCount++;
              if (moment(equipment.createtime).format('YYYY-MM-DD HH:mm:ss') >= monthStartTime) {
                return scope.secondPieChartCount++;
              }
            });
          } else if (scope.orderType === "defect") {
            scope.showMode = "percent";
            scope.secondChartName = "本月作业单数";
            scope.threeCheartName = "完成率";
            return _.each(scope.opsOrder, function(order) {
              var orderCreateTime;
              if (order.type === scope.orderType) {
                orderCreateTime = moment(order.createtime).format('YYYY-MM-DD HH:mm:ss');
                getUnfinishMonthCompletionData(order, monthStartTime, monthEndTime, orderCreateTime);
                scope.secondPieChartAllCount++;
                if (orderCreateTime >= monthStartTime) {
                  scope.secondPieChartCount++;
                }
                scope.thirdPieChartAllCount++;
                if (order.phase.nextNode === null) {
                  return scope.thirdPieChartCount++;
                }
              }
            });
          } else if (scope.orderType === "plan") {
            scope.showMode = "count";
            scope.secondChartName = "本月作业项";
            scope.threeCheartName = "发生异常设备的数量";
            equipments = [];
            allContent = [];
            alarmEquipments = [];
            _.each(scope.opsOrder, function(order) {
              var contents, orderCreateTime;
              if (order.type === scope.orderType) {
                orderCreateTime = moment(order.createtime).format('YYYY-MM-DD HH:mm:ss');
                getUnfinishMonthCompletionData(order, monthStartTime, monthEndTime, orderCreateTime);
                contents = JSON.parse(order.nodes[0].contents[0].content).content;
                scope.secondPieChartAllCount = scope.secondPieChartAllCount + contents.length;
                if (orderCreateTime >= monthStartTime) {
                  scope.secondPieChartCount = scope.secondPieChartCount + contents.length;
                }
                return _.each(contents, function(content) {
                  allContent.push(content);
                  equipments = _.filter(equipments, function(equipment) {
                    return equipment.station !== content.station || equipment.equipment !== content.equipment;
                  });
                  return equipments.push({
                    station: content.station,
                    equipment: content.equipment,
                    createtime: order.createtime
                  });
                });
              }
            });
            _.each(allContent, function(content) {
              if (content.status === 1) {
                return alarmEquipments.push(content.station + "." + content.equipment);
              }
            });
            alarmEquipments = _.uniq(alarmEquipments);
            scope.thirdPieChartAllCount = equipments.length;
            return scope.thirdPieChartCount = alarmEquipments.length;
          }
        };
      })(this);
      getTypeOrderTotal = (function(_this) {
        return function() {
          var filter;
          filter = scope.project.getIds();
          scope.nowTime = moment().format();
          scope.oneYearAgo = moment(scope.nowTime).subtract(12, 'month').startOf('day').format();
          filter.createtime = {
            "$gte": scope.oneYearAgo,
            "$lte": scope.nowTime
          };
          return _this.commonService.loadProjectModelByService('tasks', filter, null, function(err, data) {
            if (data) {
              scope.opsOrder = data;
              return processOrderData();
            }
          });
        };
      })(this);
      init = (function(_this) {
        return function() {
          scope.opsOrder = [];
          scope.secondPieChartCount = 0;
          scope.secondPieChartAllCount = 0;
          scope.thirdPieChartCount = 0;
          scope.thirdPieChartAllCount = 0;
          scope.showMode = "count";
          scope.nowTime = "";
          scope.oneYearAgo = "";
          scope.secondChartName = "本月设备作业台数";
          scope.threeCheartName = "本月发生异常单数";
          scope.typeOrderTotal = 0;
          scope.opsUnfinish = 0;
          scope.opsMonthOrder = 0;
          scope.opsMonthFinish = 0;
          scope.opsMonthUnfinish = 0;
          scope.orderType = "all";
          subscribeOrderType();
          getTypeOrderTotal();
          return subscribeTasks();
        };
      })(this);
      return init();
    };

    OrderSituationDirective.prototype.resize = function(scope) {};

    OrderSituationDirective.prototype.dispose = function(scope) {
      var _ref, _ref1;
      if ((_ref = scope.maintasksSubscri) != null) {
        _ref.dispose();
      }
      return (_ref1 = scope.subscribeOrderType) != null ? _ref1.dispose() : void 0;
    };

    return OrderSituationDirective;

  })(base.BaseDirective);
  return exports = {
    OrderSituationDirective: OrderSituationDirective
  };
});
