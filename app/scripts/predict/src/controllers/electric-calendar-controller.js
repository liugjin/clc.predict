// Generated by IcedCoffeeScript 108.0.13

/*
* File: electric-calendar-controller
* User: Pu
* Date: 2020/03/16
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var ElectricCalendarController, exports;
  ElectricCalendarController = (function(_super) {
    __extends(ElectricCalendarController, _super);

    function ElectricCalendarController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      ElectricCalendarController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return ElectricCalendarController;

  })(base.ProjectBaseController);
  return exports = {
    ElectricCalendarController: ElectricCalendarController
  };
});
