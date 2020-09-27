// Generated by IcedCoffeeScript 108.0.13

/*
* File: scrum-controller
* User: Dow
* Date: 2/27/2015
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.web', '../../services/predict/service-manager'], function(web, sm) {
  var PortalController, exports;
  PortalController = (function(_super) {
    __extends(PortalController, _super);

    function PortalController() {
      PortalController.__super__.constructor.call(this, sm);
      this.predictService = sm.getService('predict');
    }

    PortalController.prototype.onRpc = function(method, options, callback) {
      return this.predictService.rpc(method, options, callback);
    };

    return PortalController;

  })(web.PortalController);
  return exports = {
    PortalController: PortalController
  };
});
