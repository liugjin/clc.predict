// Generated by IcedCoffeeScript 108.0.13

/*
* File: log-system-controller
* User: Pu
* Date: 2020/02/21
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var LogSystemController, exports;
  LogSystemController = (function(_super) {
    __extends(LogSystemController, _super);

    function LogSystemController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      LogSystemController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return LogSystemController;

  })(base.ProjectBaseController);
  return exports = {
    LogSystemController: LogSystemController
  };
});
