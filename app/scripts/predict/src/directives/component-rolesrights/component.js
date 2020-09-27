// Generated by IcedCoffeeScript 108.0.13

/*
* File: component-rolesrights-directive
* User: James
* Date: 2018/11/17
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var ComponentRolesrightsDirective, exports;
  ComponentRolesrightsDirective = (function(_super) {
    __extends(ComponentRolesrightsDirective, _super);

    function ComponentRolesrightsDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.recurStation = __bind(this.recurStation, this);
      this.init = __bind(this.init, this);
      this.show = __bind(this.show, this);
      ComponentRolesrightsDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.id = "component-rolesrights";
      this.commonService = commonService;
      this.urlPath = $window.location.href.substr(0, $window.location.href.indexOf("#"));
      this.roleService = commonService.modelEngine.modelManager.getService("roles");
    }

    ComponentRolesrightsDirective.prototype.setScope = function() {};

    ComponentRolesrightsDirective.prototype.setCSS = function() {
      return css;
    };

    ComponentRolesrightsDirective.prototype.setTemplate = function() {
      return view;
    };

    ComponentRolesrightsDirective.prototype.show = function(scope, element, attrs) {
      this.scope = scope;
      return this.init();
    };

    ComponentRolesrightsDirective.prototype.init = function() {
      var elem, rootItem, roots, _i, _len;
      this.scope.allStationFlag = true;
      this.scope.allEquipTypeFlag = true;
      this.scope.allOperatorFlag = true;
      this.scope.allModuleFlag = true;
      this.scope.roleObject = null;
      this.scope.current = {
        user: this.scope.project.model.user,
        project: this.scope.project.model.project,
        name: "",
        role: "",
        desc: "",
        portal: "",
        group: "",
        index: 0,
        stations: ["_all"],
        operations: ["_all"],
        categories: ["_all"],
        modules: ["_all"],
        commands: [],
        services: ["_all"],
        users: [],
        createtime: new Date()
      };
      this.scope.allStationCheckFlags = {};
      this.scope.allEquipTypeCheckFlags = {};
      this.scope.allModuleCheckFlags = {};
      this.scope.allOperatorCheckFlags = {};
      this.scope.stations = this.scope.project.stations.items;
      roots = _.filter(this.scope.project.stations.items, (function(_this) {
        return function(val, key) {
          return val.model.parent === "";
        };
      })(this));
      this.htmlstr = "";
      for (_i = 0, _len = roots.length; _i < _len; _i++) {
        rootItem = roots[_i];
        this.htmlstr += '<div class="repeat-label"><md-checkbox ng-model="allStationCheckFlags[\'' + rootItem.model.station + '\']"  id="station-' + rootItem.model.station + '" ng-change="changeStations(\'' + rootItem.model.station + '\')" ng-disabled="allStationFlag" with-gap=false label="' + rootItem.model.name + '"></md-checkbox>';
        this.recurStation(rootItem, this.htmlstr);
      }
      this.htmlstr += "</div>";
      elem = this.$compile(this.htmlstr)(this.scope);
      $('#recurestationid').append(elem);
      this.resetCheckFlags();
      this.scope.equipmentTypes = this.scope.project.dictionary.equipmenttypes.items;
      this.scope.changeStations = (function(_this) {
        return function(refItem) {};
      })(this);
      this.commonService.modelEngine.modelManager.$http.get(this.urlPath + "res/roles/modules.json").then((function(_this) {
        return function(data) {
          var moduleItem, tmpModuleItem, tmpModules, _j, _k, _len1, _len2, _ref, _results;
          _this.scope.modules = _.filter(data.data.modules, function(dataItem) {
            return _.isEmpty(dataItem.parent);
          });
          _ref = _this.scope.modules;
          _results = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            moduleItem = _ref[_j];
            _this.scope.allModuleCheckFlags[moduleItem.module] = false;
            tmpModules = _.filter(data.data.modules, function(refData) {
              return refData.parent === moduleItem.module;
            });
            for (_k = 0, _len2 = tmpModules.length; _k < _len2; _k++) {
              tmpModuleItem = tmpModules[_k];
              _this.scope.allModuleCheckFlags[tmpModuleItem.module] = false;
            }
            _results.push(moduleItem.submodules = tmpModules);
          }
          return _results;
        };
      })(this));
      this.commonService.modelEngine.modelManager.$http.get(this.urlPath + "res/roles/operations.json").then((function(_this) {
        return function(data) {
          var operatorItem, tmpOperatorItem, tmpOperators, _j, _k, _len1, _len2, _ref, _results;
          _this.scope.operators = _.filter(data.data.operations, function(dataItem) {
            return _.isEmpty(dataItem.parent);
          });
          _ref = _this.scope.operators;
          _results = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            operatorItem = _ref[_j];
            _this.scope.allOperatorCheckFlags[operatorItem.operation] = false;
            tmpOperators = _.filter(data.data.operations, function(refData) {
              return refData.parent === operatorItem.operation;
            });
            for (_k = 0, _len2 = tmpOperators.length; _k < _len2; _k++) {
              tmpOperatorItem = tmpOperators[_k];
              _this.scope.allOperatorCheckFlags[tmpOperatorItem.operation] = false;
            }
            _results.push(operatorItem.suboperators = angular.copy(tmpOperators));
          }
          return _results;
        };
      })(this));
      this.query();
      this.scope.changeModule = (function(_this) {
        return function(refItem) {
          var dataItem, tmpModules, _j, _len1, _ref, _results;
          if (!_this.scope.allModuleCheckFlags[refItem.module]) {
            tmpModules = _.filter(_this.scope.modules, function(refData) {
              var subModuleItem, _j, _len1, _ref;
              _ref = refData.submodules;
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                subModuleItem = _ref[_j];
                if (subModuleItem.module === refItem.module) {
                  return true;
                }
              }
              return false;
            });
            if (tmpModules.length > 0) {
              _this.scope.allModuleCheckFlags[tmpModules[0].module] = !_this.scope.allModuleCheckFlags[refItem.module];
            }
          }
          if (refItem.submodules) {
            _ref = refItem.submodules;
            _results = [];
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              dataItem = _ref[_j];
              _results.push(_this.scope.allModuleCheckFlags[dataItem.module] = !_this.scope.allModuleCheckFlags[refItem.module]);
            }
            return _results;
          }
        };
      })(this);
      this.scope.changeOperator = (function(_this) {
        return function(refItem) {
          var dataItem, tmpOperators, _j, _len1, _ref, _results;
          if (!_this.scope.allOperatorCheckFlags[refItem.operation]) {
            tmpOperators = _.filter(_this.scope.operators, function(refData) {
              var subOperatorItem, _j, _len1, _ref;
              _ref = refData.suboperators;
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                subOperatorItem = _ref[_j];
                if (subOperatorItem.operation === refItem.operation) {
                  return true;
                }
              }
              return false;
            });
            if (tmpOperators.length > 0) {
              _this.scope.allOperatorCheckFlags[tmpOperators[0].operation] = !_this.scope.allOperatorCheckFlags[refItem.operation];
            }
          }
          if (refItem.suboperators) {
            _ref = refItem.suboperators;
            _results = [];
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              dataItem = _ref[_j];
              _results.push(_this.scope.allOperatorCheckFlags[dataItem.operation] = !_this.scope.allOperatorCheckFlags[refItem.operation]);
            }
            return _results;
          }
        };
      })(this);
      this.scope.addRole = (function(_this) {
        return function() {
          return _this.scope.roleObject = _this.scope.current = {
            user: _this.scope.project.model.user,
            project: _this.scope.project.model.project,
            name: "",
            role: "",
            desc: "",
            portal: "",
            group: "",
            index: 0,
            stations: ["_all"],
            operations: ["_all"],
            categories: ["_all"],
            modules: ["_all"],
            commands: [],
            services: ["_all"],
            users: [],
            createtime: new Date()
          };
        };
      })(this);
      this.scope.delRole = (function(_this) {
        return function() {
          return _this.roleService.remove(_this.scope.roleObject, function(err, data) {
            _this.query();
            return _this.display(err, '操作成功！');
          });
        };
      })(this);
      this.scope.saveRole = (function(_this) {
        return function(type) {
          var refData, tmpEquipTypes, tmpModules, tmpOperators, tmpStations;
          if (type === 1 && $("#roleLists").find(".active").length === 0) {
            return _this.display("请先选择一条角色信息!!");
          } else if (type === 1 && $("#roleLists").find(".active").length > 0) {
            refData = _.find(_this.scope.roles, function(d) {
              return d.role === $("#roleLists").find(".active")[0].firstChild.innerText;
            });
            _this.scope.roleObject = refData;
            _this.scope.current = {
              name: refData.name,
              role: refData.role,
              desc: refData.desc,
              portal: refData.portal,
              group: refData.group,
              index: refData.index,
              _id: refData._id
            };
          }
          _this.scope.roleObject.name = _this.scope.current.name;
          _this.scope.roleObject.group = _this.scope.current.group;
          _this.scope.roleObject.index = _this.scope.current.index;
          _this.scope.roleObject.desc = _this.scope.current.desc;
          _this.scope.roleObject.portal = _this.scope.current.portal;
          if (_this.scope.allStationFlag) {
            _this.scope.roleObject.stations = ["_all"];
          } else {
            tmpStations = [];
            _.mapObject(_this.scope.allStationCheckFlags, function(val, key) {
              if (val) {
                return tmpStations.push(key);
              }
            });
            _this.scope.roleObject.stations = tmpStations;
          }
          if (_this.scope.allEquipTypeFlag) {
            _this.scope.roleObject.categories = ["_all"];
          } else {
            tmpEquipTypes = [];
            _.mapObject(_this.scope.allEquipTypeCheckFlags, function(val, key) {
              if (val) {
                return tmpEquipTypes.push(key);
              }
            });
            _this.scope.roleObject.categories = tmpEquipTypes;
          }
          if (_this.scope.allModuleFlag) {
            _this.scope.roleObject.modules = ["_all"];
          } else {
            tmpModules = [];
            _.mapObject(_this.scope.allModuleCheckFlags, function(val, key) {
              if (val) {
                return tmpModules.push(key);
              }
            });
            _this.scope.roleObject.modules = tmpModules;
          }
          if (_this.scope.allOperatorFlag) {
            _this.scope.roleObject.operations = ["_all"];
          } else {
            tmpOperators = [];
            _.mapObject(_this.scope.allOperatorCheckFlags, function(val, key) {
              if (val) {
                return tmpOperators.push(key);
              }
            });
            _this.scope.roleObject.operations = tmpOperators;
          }
          return _this.roleService.save(_this.scope.roleObject, function(err, data) {
            _this.query();
            return _this.display(err, '操作成功！');
          });
        };
      })(this);
      return this.scope.roleDetails = (function(_this) {
        return function(refData, key) {
          var categorieItem, moduleItem, operationItem, stationItem, _j, _k, _l, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3, _results;
          $('.roles-active').removeClass('active');
          $('#roles' + key).addClass('active');
          _this.resetCheckFlags();
          _this.scope.roleObject = refData;
          _this.scope.current = {
            name: refData.name,
            role: refData.role,
            desc: refData.desc,
            portal: refData.portal,
            group: refData.group,
            index: refData.index,
            _id: refData._id
          };
          if (refData.stations[0] === "_all") {
            _this.scope.allStationFlag = true;
          } else {
            _this.scope.allStationFlag = false;
            _ref = refData.stations;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              stationItem = _ref[_j];
              _this.scope.allStationCheckFlags[stationItem] = true;
            }
          }
          if (refData.categories[0] === "_all") {
            _this.scope.allEquipTypeFlag = true;
          } else {
            _this.scope.allEquipTypeFlag = false;
            _ref1 = refData.categories;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              categorieItem = _ref1[_k];
              _this.scope.allEquipTypeCheckFlags[categorieItem] = true;
            }
          }
          if (refData.modules[0] === "_all") {
            _this.scope.allModuleFlag = true;
          } else {
            _this.scope.allModuleFlag = false;
            _ref2 = refData.modules;
            for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
              moduleItem = _ref2[_l];
              _this.scope.allModuleCheckFlags[moduleItem] = true;
            }
          }
          if (refData.operations[0] === "_all") {
            return _this.scope.allOperatorFlag = true;
          } else {
            _this.scope.allOperatorFlag = false;
            _ref3 = refData.operations;
            _results = [];
            for (_m = 0, _len4 = _ref3.length; _m < _len4; _m++) {
              operationItem = _ref3[_m];
              _results.push(_this.scope.allOperatorCheckFlags[operationItem] = true);
            }
            return _results;
          }
        };
      })(this);
    };

    ComponentRolesrightsDirective.prototype.recurStation = function(restation) {
      var stationItem, _i, _len, _ref;
      if (restation.stations.length > 0) {
        this.htmlstr += '<div style="margin-left: 30px;margin-top: .5rem">';
        _ref = restation.stations;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          stationItem = _ref[_i];
          this.htmlstr += '<div>';
          this.htmlstr += '<md-checkbox ng-model="allStationCheckFlags[\'' + stationItem.model.station + '\']"  id="station-' + stationItem.model.station + '" ng-change="changeStations(\'' + stationItem.model.station + '\')" ng-disabled="allStationFlag" with-gap=false label="' + stationItem.model.name + '"></md-checkbox>';
          this.recurStation(stationItem);
        }
        return this.htmlstr += "</div>";
      } else {
        this.htmlstr += "</div>";
      }
    };

    ComponentRolesrightsDirective.prototype.query = function() {
      var filter;
      filter = this.scope.project.getIds();
      return this.roleService.query(filter, null, (function(_this) {
        return function(err, model) {
          return _this.scope.roles = model;
        };
      })(this), true);
    };

    ComponentRolesrightsDirective.prototype.resetCheckFlags = function() {
      var equipmentTypeItem, moduleItem, operatorItem, stationItem, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _results;
      if (this.scope.equipmentTypes) {
        _ref = this.scope.equipmentTypes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          equipmentTypeItem = _ref[_i];
          this.scope.allEquipTypeCheckFlags[equipmentTypeItem.model.type] = false;
        }
      }
      if (this.scope.stations) {
        _ref1 = this.scope.stations;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          stationItem = _ref1[_j];
          this.scope.allStationCheckFlags[stationItem.model.station] = false;
        }
      }
      if (this.scope.modules) {
        _ref2 = this.scope.modules;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          moduleItem = _ref2[_k];
          this.scope.allModuleCheckFlags[moduleItem.module] = false;
        }
      }
      if (this.scope.operators) {
        _ref3 = this.scope.operators;
        _results = [];
        for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
          operatorItem = _ref3[_l];
          _results.push(this.scope.allOperatorCheckFlags[operatorItem.operation] = false);
        }
        return _results;
      }
    };

    ComponentRolesrightsDirective.prototype.resize = function(scope) {};

    ComponentRolesrightsDirective.prototype.dispose = function(scope) {};

    return ComponentRolesrightsDirective;

  })(base.BaseDirective);
  return exports = {
    ComponentRolesrightsDirective: ComponentRolesrightsDirective
  };
});
