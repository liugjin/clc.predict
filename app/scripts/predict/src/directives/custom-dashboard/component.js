// Generated by IcedCoffeeScript 108.0.13

/*
* File: custom-dashboard-directive
* User: David
* Date: 2019/05/06
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "json!./layout.json"], function(base, css, view, _, moment, layout) {
  var CustomDashboardDirective, exports;
  CustomDashboardDirective = (function(_super) {
    __extends(CustomDashboardDirective, _super);

    function CustomDashboardDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "custom-dashboard";
      CustomDashboardDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    CustomDashboardDirective.prototype.setScope = function() {};

    CustomDashboardDirective.prototype.setCSS = function() {
      return css;
    };

    CustomDashboardDirective.prototype.setTemplate = function() {
      return view;
    };

    CustomDashboardDirective.prototype.show = function(scope, element, attrs) {
      var config, configuration, ele, html, key, _ref, _ref1;
      if (!scope.firstload) {
        return;
      }
      try {
        config = JSON.parse(scope.project.model.layout);
      } catch (_error) {
        config = {};
      }
      key = scope.controller.$location.$$path.split("/")[1];
      configuration = (_ref = config[key]) != null ? _ref : layout[key];
      html = this.getChildrenHTML(scope, configuration);
      ele = this.$compile(html)(scope);
      element.empty();
      element.append(ele);
      key = scope.project.model.user + "." + scope.project.model.project + ".stationId";
      localStorage.setItem(key, scope.station.model.station);
      if ((_ref1 = scope.topicSubscription) != null) {
        _ref1.dispose();
      }
      return scope.topicSubscription = this.commonService.subscribeEventBus("stationId", function(msg) {
        key = scope.project.model.user + "." + scope.project.model.project + ".stationId";
        return localStorage.setItem(key, msg.message.stationId);
      });
    };

    CustomDashboardDirective.prototype.getChildrenHTML = function(scope, children) {
      var div, html, key, parameters, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4;
      html = "";
      for (_i = 0, _len = children.length; _i < _len; _i++) {
        div = children[_i];
        html += "<" + ((_ref = (_ref1 = div.component) != null ? _ref1 : div.tag) != null ? _ref : "div");
        if (div.component) {
          key = scope.project.model.user + "." + scope.project.model.project + ".stationId";
          if (localStorage.getItem(key) && div.parameters._mode !== "'fixed'" && !this.$routeParams.station) {
            div.parameters["station"] = "'" + localStorage.getItem(key) + "'";
            scope.station = _.find(scope.project.stations.items, function(item) {
              return item.model.station === localStorage.getItem(key);
            });
          }
          parameters = JSON.stringify((_ref2 = div.parameters) != null ? _ref2 : {}).replace(/"/g, "");
          html += " controller='controller' parameters=\"" + parameters + "\"";
        }
        if (div["class"]) {
          html += " class='" + div["class"] + "'";
        }
        if (div.style) {
          html += " style='" + div.style + "'";
        }
        html += ">";
        if (div.children) {
          html += this.getChildrenHTML(scope, div.children);
        }
        html += "</" + ((_ref3 = (_ref4 = div.component) != null ? _ref4 : div.tag) != null ? _ref3 : "div") + ">";
      }
      return html;
    };

    CustomDashboardDirective.prototype.resize = function(scope) {};

    CustomDashboardDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.topicSubscription) != null ? _ref.dispose() : void 0;
    };

    return CustomDashboardDirective;

  })(base.BaseDirective);
  return exports = {
    CustomDashboardDirective: CustomDashboardDirective
  };
});
