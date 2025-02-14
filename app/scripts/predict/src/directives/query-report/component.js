// Generated by IcedCoffeeScript 108.0.13

/*
* File: query-report-directive
* User: David
* Date: 2018/11/12
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(["jquery", '../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", 'angularGrid', 'gl-datepicker'], function($, base, css, view, _, moment, agGrid, gl) {
  var QueryReportDirective, exports;
  QueryReportDirective = (function(_super) {
    __extends(QueryReportDirective, _super);

    function QueryReportDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      QueryReportDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.id = "query-report";
      this.$timeout = $timeout;
    }

    QueryReportDirective.prototype.setScope = function() {
      return {
        type: "@"
      };
    };

    QueryReportDirective.prototype.setCSS = function() {
      return css;
    };

    QueryReportDirective.prototype.setTemplate = function() {
      return view;
    };

    QueryReportDirective.prototype.show = function(scope, element, attrs) {
      var checkFilter, createGridOptions, dataArray, formatData, getEquipmentName, getSignalName, getStationName, getUnit, gridOptions, loadEquipmentAndSignals, queryAlarms, querySignal, setData, setGlDatePicker, setHeader;
      scope.selectedEquips = [];
      scope.query = {
        startTime: moment().format("YYYY-MM-DD"),
        endTime: moment().format("YYYY-MM-DD")
      };
      dataArray = [
        {
          stationName: "暂无数据",
          equipmentName: "暂无数据"
        }
      ];
      switch (scope.parameters.type) {
        case 'alarm':
          scope.header = [
            {
              headerName: "告警级别",
              field: "severityName"
            }, {
              headerName: "站点名称",
              field: "stationName"
            }, {
              headerName: "设备名称",
              field: "equipmentName"
            }, {
              headerName: "告警名称",
              field: "title"
            }, {
              headerName: "开始值",
              field: "startValue"
            }, {
              headerName: "结束值",
              field: "endValue"
            }, {
              headerName: "总时长",
              field: "continuedTime"
            }, {
              headerName: "开始时间",
              field: "startTime"
            }, {
              headerName: "结束时间",
              field: "endTime"
            }
          ];
          break;
        case 'signal':
          scope.header = [
            {
              headerName: "站点名称",
              field: 'stationName'
            }, {
              headerName: "设备名称",
              field: 'equipmentName'
            }, {
              headerName: "信号",
              field: 'signalName'
            }, {
              headerName: "信号值",
              field: 'value'
            }, {
              headerName: "单位",
              field: 'unitName'
            }, {
              headerName: "采集时间",
              field: 'sampleTime'
            }
          ];
          break;
        default:
          scope.header = [
            {
              headerName: "站点",
              field: 'stationName'
            }, {
              headerName: "设备",
              field: 'equipmentName'
            }
          ];
      }
      loadEquipmentAndSignals = (function(_this) {
        return function(equipments) {
          var equip, equipmentId, station, stationId, _i, _len, _results;
          scope.equipments = [];
          scope.signals = [];
          _results = [];
          for (_i = 0, _len = equipments.length; _i < _len; _i++) {
            equip = equipments[_i];
            stationId = equip.split('.')[0];
            equipmentId = equip.split('.')[1];
            _results.push((function() {
              var _j, _len1, _ref, _results1;
              _ref = scope.project.stations.items;
              _results1 = [];
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                station = _ref[_j];
                if ((station != null ? station.model.station : void 0) === stationId) {
                  _results1.push(this.commonService.loadEquipmentById(station, equipmentId, (function(_this) {
                    return function(err, equipment) {
                      if (err) {
                        return console.log("err:", err);
                      }
                      scope.equipments.push(equipment);
                      return equipment.loadSignals(null, function(err, model) {
                        var signal, _k, _len2, _results2;
                        if (err) {
                          return console.log("err:", err);
                        }
                        _results2 = [];
                        for (_k = 0, _len2 = model.length; _k < _len2; _k++) {
                          signal = model[_k];
                          _results2.push(scope.signals.push(signal));
                        }
                        return _results2;
                      });
                    };
                  })(this)));
                } else {
                  _results1.push(void 0);
                }
              }
              return _results1;
            }).call(_this));
          }
          return _results;
        };
      })(this);
      createGridOptions = function(header) {
        var gridOptions;
        return gridOptions = {
          columnDefs: header,
          rowData: null,
          enableFilter: true,
          enableSorting: true,
          enableColResize: true,
          overlayNoRowsTemplate: " ",
          headerHeight: 41,
          rowHeight: 61
        };
      };
      setHeader = function(header) {
        if (!header || !gridOptions) {
          return;
        }
        return scope.header = header;
      };
      setData = function(data) {
        if (!gridOptions) {
          return;
        }
        return scope.data = data;
      };
      setGlDatePicker = function(element, value) {
        if (!value) {
          return;
        }
        return setTimeout(function() {
          return gl = $(element).glDatePicker({
            dowNames: ["日", "一", "二", "三", "四", "五", "六"],
            monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
            selectedDate: moment(value).toDate(),
            onClick: function(target, cell, date, data) {
              var day, month;
              month = date.getMonth() + 1;
              if (month < 10) {
                month = "0" + month;
              }
              day = date.getDate();
              if (day < 10) {
                day = "0" + day;
              }
              return target.val(date.getFullYear() + "-" + month + "-" + day).trigger("change");
            }
          });
        }, 500);
      };
      checkFilter = function() {
        if (!scope.selectedEquips || (!scope.selectedEquips.length)) {
          M.toast({
            html: '请选择设备！'
          });
          return true;
        }
        if (moment(scope.query.startTime).isAfter(moment(scope.query.endTime))) {
          M.toast({
            html: '开始时间大于结束时间！'
          });
          return true;
        }
        return false;
      };
      scope.exportReport = function(name) {
        var reportName;
        if (!gridOptions) {
          return;
        }
        reportName = name + moment().format("YYYYMMDDHHmmss") + ".csv";
        return gridOptions.api.exportDataAsCsv({
          fileName: reportName,
          allColumns: true,
          skipGroups: true
        });
      };
      queryAlarms = (function(_this) {
        return function(page, pageItems) {
          var data, filter, paging;
          if (page == null) {
            page = 1;
          }
          if (pageItems == null) {
            pageItems = 50;
          }
          if (checkFilter()) {
            return;
          }
          filter = scope.project.getIds();
          filter["$or"] = _.map(scope.selectedEquips, function(equip) {
            if (equip.split(".").length > 1) {
              return {
                station: equip.split('.')[0],
                equipment: equip.split('.')[1]
              };
            } else {
              return {
                station: equip.split('.')[0]
              };
            }
          });
          filter.startTime = moment(scope.query.startTime).startOf('day');
          filter.endTime = moment(scope.query.endTime).endOf('day');
          paging = {
            page: page,
            pageItems: pageItems
          };
          data = {
            filter: filter,
            fields: null,
            paging: paging
          };
          return _this.commonService.reportingService.queryEventRecords(data, function(err, records, paging2) {
            var pCount, tmprecords, _i, _results;
            if (err || records.length < 1) {
              return setData(null);
            }
            pCount = (paging2 != null ? paging2.pageCount : void 0) || 0;
            if (pCount <= 6) {
              if (paging2 != null) {
                paging2.pages = (function() {
                  _results = [];
                  for (var _i = 1; 1 <= pCount ? _i <= pCount : _i >= pCount; 1 <= pCount ? _i++ : _i--){ _results.push(_i); }
                  return _results;
                }).apply(this);
              }
            } else if (page > 3 && page < pCount - 2) {
              if (paging2 != null) {
                paging2.pages = [1, page - 2, page - 1, page, page + 1, page + 2, pCount];
              }
            } else if (page <= 3) {
              if (paging2 != null) {
                paging2.pages = [1, 2, 3, 4, 5, 6, pCount];
              }
            } else if (page >= pCount - 2) {
              if (paging2 != null) {
                paging2.pages = [1, pCount - 5, pCount - 4, pCount - 3, pCount - 2, pCount - 1, pCount];
              }
            }
            scope.pagination = paging2;
            tmprecords = _.map(records, function(record) {
              if (_.isEmpty(record.endTime)) {
                record.continuedTime = _this.calTimes(moment().diff(moment(record.startTime, 'YYYY-MM-DD HH:mm:ss'), 'seconds'));
                record.startTime = moment(record.startTime).format('YYYY-MM-DD HH:mm:ss');
              } else {
                record.continuedTime = _this.calTimes(moment(record.endTime, "YYYY-MM-DD HH:mm:ss").diff(moment(record.startTime, 'YYYY-MM-DD HH:mm:ss'), 'seconds'));
                record.startTime = moment(record.startTime).format('YYYY-MM-DD HH:mm:ss');
                record.endTime = moment(record.endTime).format('YYYY-MM-DD HH:mm:ss');
              }
              return record;
            });
            dataArray = tmprecords;
            return setData(dataArray);
          });
        };
      })(this);
      querySignal = (function(_this) {
        return function(page, pageItems) {
          var data, filter, paging;
          if (page == null) {
            page = 1;
          }
          if (pageItems == null) {
            pageItems = 50;
          }
          if (checkFilter()) {
            return;
          }
          filter = scope.project.getIds();
          filter["$or"] = _.map(scope.selectedEquips, function(equip) {
            if (equip.split(".").length > 1) {
              return {
                station: equip.split('.')[0],
                equipment: equip.split('.')[1]
              };
            } else {
              return {
                station: equip.split('.')[0]
              };
            }
          });
          filter.startTime = moment(scope.query.startTime).startOf('day');
          filter.endTime = moment(scope.query.endTime).endOf('day');
          paging = {
            page: page,
            pageItems: pageItems
          };
          data = {
            filter: filter,
            fields: null,
            paging: paging
          };
          return _this.commonService.reportingService.querySignalRecords(data, function(err, records, paging2) {
            var pCount, _i, _results;
            if (err || records.length < 1) {
              return setData(null);
            }
            pCount = (paging2 != null ? paging2.pageCount : void 0) || 0;
            if (pCount <= 6) {
              if (paging2 != null) {
                paging2.pages = (function() {
                  _results = [];
                  for (var _i = 1; 1 <= pCount ? _i <= pCount : _i >= pCount; 1 <= pCount ? _i++ : _i--){ _results.push(_i); }
                  return _results;
                }).apply(this);
              }
            } else if (page > 3 && page < pCount - 2) {
              if (paging2 != null) {
                paging2.pages = [1, page - 2, page - 1, page, page + 1, page + 2, pCount];
              }
            } else if (page <= 3) {
              if (paging2 != null) {
                paging2.pages = [1, 2, 3, 4, 5, 6, pCount];
              }
            } else if (page >= pCount - 2) {
              if (paging2 != null) {
                paging2.pages = [1, pCount - 5, pCount - 4, pCount - 3, pCount - 2, pCount - 1, pCount];
              }
            }
            scope.pagination = paging2;
            dataArray = records;
            formatData(dataArray);
            return setData(dataArray);
          });
        };
      })(this);
      scope.queryPage = function(page) {
        var paging;
        paging = scope.pagination;
        if (!paging) {
          return;
        }
        if (page === 'next') {
          page = paging.page + 1;
        } else if (page === 'previous') {
          page = paging.page - 1;
        }
        if (page > paging.pageCount || page < 1) {
          return;
        }
        if (scope.parameters.type === 'signal') {
          return querySignal(page, paging.pageItems);
        } else if (scope.parameters.type === 'alarm') {
          return queryAlarms(page, paging.pageItems);
        } else {
          return alert('err');
        }
      };
      getStationName = function(stationId) {
        var item, _i, _len, _ref;
        _ref = scope.project.stations.items;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item.model.station === stationId) {
            return item.model.name;
          }
        }
        return stationId;
      };
      getEquipmentName = function(equipmentId) {
        var item, tempEquipment, _i, _len, _ref;
        tempEquipment = equipmentId.split('.');
        _ref = scope.equipments;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item.model.equipment === tempEquipment[1] && item.model.station === tempEquipment[0]) {
            return item.model.name;
          }
        }
        return equipmentId;
      };
      getSignalName = function(signalId) {
        var item, _i, _len, _ref;
        _ref = scope.signals;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item.model.signal === signalId) {
            return item.model.name;
          }
        }
        return signalId;
      };
      scope.queryReport = function(type) {
        switch (type) {
          case "alarm":
            return queryAlarms();
          case "signal":
            return querySignal();
          default:
            return console.log("err:query type is error. ", type);
        }
      };
      getUnit = function(unitid) {
        var item, unitItem, _i, _len, _ref, _ref1;
        if (!unitid) {
          return '';
        }
        _ref1 = (_ref = scope.project.dictionary) != null ? _ref.signaltypes.items : void 0;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          item = _ref1[_i];
          unitItem = item.model;
          if (unitItem.type === unitid) {
            return unitItem.unit;
          }
        }
        return unitid;
      };
      formatData = function(records) {
        var finalData;
        if (records == null) {
          records = [];
        }
        finalData = [];
        finalData = _.map(records, (function(_this) {
          return function(record) {
            var _ref;
            return _.extend(record, {
              unitName: getUnit(record.unit),
              stationName: getStationName(record.station),
              equipmentName: getEquipmentName(record.station + "." + record.equipment),
              value: (_ref = record.value) != null ? _ref.toFixed(2) : void 0,
              signalName: getSignalName(record.signal),
              sampleTime: moment(record.timestamp).format("YYYY-MM-DD HH:mm:ss")
            });
          };
        })(this));
        return finalData;
      };
      gridOptions = createGridOptions(scope.header);
      setHeader(scope.header);
      setData(dataArray);
      setGlDatePicker($('#start-time-input')[0], scope.query.startTime);
      setGlDatePicker($('#end-time-input')[0], scope.query.startTime);
      return this.commonService.subscribeEventBus('checkEquips', (function(_this) {
        return function(msg) {
          var equipments, stations;
          scope.selectedEquips = [];
          if (!(msg != null ? msg.message.length : void 0)) {
            return;
          }
          stations = _.filter(msg.message, function(item) {
            return item.level === "station";
          });
          equipments = _.filter(msg.message, function(item) {
            var _ref;
            return item.level === "equipment" && (_ref = item.station, __indexOf.call(_.pluck(stations, "id"), _ref) < 0);
          });
          if (stations != null) {
            stations.forEach(function(value) {
              return scope.selectedEquips.push(value.id);
            });
          }
          if (equipments != null) {
            equipments.forEach(function(value) {
              return scope.selectedEquips.push((value != null ? value.station : void 0) + '.' + (value != null ? value.id : void 0));
            });
          }
          if (scope.parameters.type === "signal") {
            return loadEquipmentAndSignals(scope.selectedEquips);
          }
        };
      })(this));
    };

    QueryReportDirective.prototype.calTimes = function(refTime) {
      var days, daysY, hours, hoursY, minY, mins, sTime;
      sTime = "";
      days = Math.floor(refTime / 86400);
      daysY = refTime % 86400;
      hours = Math.floor(daysY / 3600);
      hoursY = daysY % 3600;
      mins = Math.floor(hoursY / 60);
      minY = hoursY % 60;
      if (days > 0) {
        sTime = sTime + days + "天 ";
      } else {
        sTime = "0天 ";
      }
      if (hours > 0) {
        sTime = sTime + hours + "时 ";
      } else {
        sTime = sTime + "0时 ";
      }
      if (mins > 0) {
        sTime = sTime + mins + "分 ";
      } else {
        sTime = sTime + "0分 ";
      }
      if (minY > 0) {
        sTime = sTime + minY + "秒";
      } else {
        sTime = sTime + "0秒";
      }
      return sTime;
    };

    QueryReportDirective.prototype.resize = function() {
      return typeof gridOptions !== "undefined" && gridOptions !== null ? gridOptions.api.refreshView() : void 0;
    };

    QueryReportDirective.prototype.dispose = function(scope) {};

    return QueryReportDirective;

  })(base.BaseDirective);
  return exports = {
    QueryReportDirective: QueryReportDirective
  };
});
