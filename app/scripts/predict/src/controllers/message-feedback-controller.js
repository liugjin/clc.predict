// Generated by IcedCoffeeScript 108.0.13

/*
* File: message-feedback-controller
* User: Pu
* Date: 2020/03/30
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var MessageFeedbackController, exports;
  MessageFeedbackController = (function(_super) {
    __extends(MessageFeedbackController, _super);

    function MessageFeedbackController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      MessageFeedbackController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return MessageFeedbackController;

  })(base.ProjectBaseController);
  return exports = {
    MessageFeedbackController: MessageFeedbackController
  };
});
