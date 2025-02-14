// Generated by IcedCoffeeScript 108.0.13

/*
* File: alarm-number-box-directive
* User: David
* Date: 2019/02/18
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var AlarmNumberBoxDirective, exports;
  AlarmNumberBoxDirective = (function(_super) {
    __extends(AlarmNumberBoxDirective, _super);

    function AlarmNumberBoxDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "alarm-number-box";
      AlarmNumberBoxDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    AlarmNumberBoxDirective.prototype.setScope = function() {};

    AlarmNumberBoxDirective.prototype.setCSS = function() {
      return css;
    };

    AlarmNumberBoxDirective.prototype.setTemplate = function() {
      return view;
    };

    AlarmNumberBoxDirective.prototype.show = function(scope, element, attrs) {};

    AlarmNumberBoxDirective.prototype.resize = function(scope) {};

    AlarmNumberBoxDirective.prototype.dispose = function(scope) {};

    return AlarmNumberBoxDirective;

  })(base.BaseDirective);
  return exports = {
    AlarmNumberBoxDirective: AlarmNumberBoxDirective
  };
});
