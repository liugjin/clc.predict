// Generated by IcedCoffeeScript 108.0.13

/*
* File: search-input-directive
* User: David
* Date: 2018/11/05
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var SearchInputDirective, exports;
  SearchInputDirective = (function(_super) {
    __extends(SearchInputDirective, _super);

    function SearchInputDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      SearchInputDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.id = "search-input";
    }

    SearchInputDirective.prototype.setScope = function() {
      return {
        placeholder: '@'
      };
    };

    SearchInputDirective.prototype.setCSS = function() {
      return css;
    };

    SearchInputDirective.prototype.setTemplate = function() {
      return view;
    };

    SearchInputDirective.prototype.show = function(scope, element, attrs) {
      return scope.$watch("search", (function(_this) {
        return function(search) {
          return _this.commonService.publishEventBus('search', search);
        };
      })(this));
    };

    SearchInputDirective.prototype.dispose = function(scope) {};

    return SearchInputDirective;

  })(base.BaseDirective);
  return exports = {
    SearchInputDirective: SearchInputDirective
  };
});
