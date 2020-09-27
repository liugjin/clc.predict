// Generated by IcedCoffeeScript 108.0.13

/*
* File: system-setting-directive
* User: David
* Date: 2018/11/22
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "json!../../../setting.json"], function(base, css, view, _, moment, setting) {
  var SystemSettingDirective, exports;
  SystemSettingDirective = (function(_super) {
    __extends(SystemSettingDirective, _super);

    function SystemSettingDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "system-setting";
      SystemSettingDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.$routeParams = $routeParams;
      this.projectService = commonService.modelEngine.modelManager.getService("project");
    }

    SystemSettingDirective.prototype.setScope = function() {};

    SystemSettingDirective.prototype.setCSS = function() {
      return css;
    };

    SystemSettingDirective.prototype.setTemplate = function() {
      return view;
    };

    SystemSettingDirective.prototype.show = function(scope, element, attrs) {
      var filter;
      scope.projectObj = {};
      scope.tmpMyProject = this.commonService.modelEngine.storage.get("myproject");
      filter = {};
      filter.user = this.$routeParams.user;
      filter.project = this.$routeParams.project;
      this.projectService.query(filter, null, (function(_this) {
        return function(err, datas) {
          if (datas) {
            datas.setting.menus = setting.menus;
            scope.projectObj = datas;
            if (_.isEmpty(scope.projectObj.setting) || scope.projectObj["private"]) {
              return scope.setting = setting;
            } else {
              return scope.setting = scope.projectObj.setting;
            }
          }
        };
      })(this));
      return scope.saveSetting = (function(_this) {
        return function() {
          scope.projectObj.setting = scope.setting;
          scope.projectObj.name = scope.setting.name;
          scope.tmpMyProject.name = scope.setting.name;
          return _this.projectService.save(scope.projectObj, function(err, data) {
            _this.commonService.modelEngine.storage.set("myproject", scope.tmpMyProject);
            return _this.display(err, '操作成功！');
          });
        };
      })(this);
    };

    SystemSettingDirective.prototype.resize = function(scope) {};

    SystemSettingDirective.prototype.dispose = function(scope) {};

    return SystemSettingDirective;

  })(base.BaseDirective);
  return exports = {
    SystemSettingDirective: SystemSettingDirective
  };
});
