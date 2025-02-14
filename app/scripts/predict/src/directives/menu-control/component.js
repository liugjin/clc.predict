// Generated by IcedCoffeeScript 108.0.13

/*
* File: menu-control-directive
* User: David
* Date: 2018/11/29
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var MenuControlDirective, exports;
  MenuControlDirective = (function(_super) {
    __extends(MenuControlDirective, _super);

    function MenuControlDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.link = __bind(this.link, this);
      this.id = "menu-control";
      MenuControlDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    MenuControlDirective.prototype.setScope = function() {};

    MenuControlDirective.prototype.setCSS = function() {
      return css;
    };

    MenuControlDirective.prototype.setTemplate = function() {
      return view;
    };

    MenuControlDirective.prototype.link = function(scope, element, attrs) {
      return scope.menuControl = (function(_this) {
        return function() {
          _this.publishEventBus('menuState', {
            'menu': 'menu'
          });
          return _this.$timeout(function() {
            return $(window).resize();
          });
        };
      })(this);
    };

    MenuControlDirective.prototype.resize = function(scope) {};

    MenuControlDirective.prototype.dispose = function(scope) {};

    return MenuControlDirective;

  })(base.BaseDirective);
  return exports = {
    MenuControlDirective: MenuControlDirective
  };
});
