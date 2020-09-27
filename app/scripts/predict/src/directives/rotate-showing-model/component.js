// Generated by IcedCoffeeScript 108.0.13

/*
* File: rotate-showing-model-directive
* User: David
* Date: 2019/03/28
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var RotateShowingModelDirective, exports;
  RotateShowingModelDirective = (function(_super) {
    __extends(RotateShowingModelDirective, _super);

    function RotateShowingModelDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "rotate-showing-model";
      RotateShowingModelDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    RotateShowingModelDirective.prototype.setScope = function() {};

    RotateShowingModelDirective.prototype.setCSS = function() {
      return css;
    };

    RotateShowingModelDirective.prototype.setTemplate = function() {
      return view;
    };

    RotateShowingModelDirective.prototype.show = function(scope, element, attrs) {
      var changeShowingModel, rotate, rotateShowingModel, showingModelList, time, _ref, _ref1, _ref2, _ref3;
      time = ((_ref = scope.parameters) != null ? _ref.time : void 0) ? (_ref1 = scope.parameters) != null ? _ref1.time : void 0 : 10000;
      rotate = typeof ((_ref2 = scope.parameters) != null ? _ref2.rotate : void 0) === "boolean" ? (_ref3 = scope.parameters) != null ? _ref3.rotate : void 0 : true;
      scope.setInterval = null;
      showingModelList = [
        {
          element: 'show-object3D',
          type: 'object3D'
        }, {
          element: 'show-comprehensive',
          type: 'capacityObject3D',
          subType: 'ratio-comprehensive'
        }, {
          element: 'show-space',
          type: 'capacityObject3D',
          subType: 'ratio-space'
        }, {
          element: 'show-power',
          type: 'capacityObject3D',
          subType: 'ratio-power'
        }, {
          element: 'show-cooling',
          type: 'capacityObject3D',
          subType: 'ratio-cooling'
        }, {
          element: 'show-ports',
          type: 'capacityObject3D',
          subType: 'ratio-ports'
        }, {
          element: 'show-weight',
          type: 'capacityObject3D',
          subType: 'ratio-weight'
        }
      ];
      scope.rotateIndex = 0;
      changeShowingModel = (function(_this) {
        return function(index) {
          var showingModel;
          if (index >= showingModelList.length) {
            return console.warn("rotate index is err");
          }
          showingModel = showingModelList[index];
          _this.commonService.publishEventBus("changeShowModel", {
            type: showingModel.type,
            subType: showingModel.subType
          });
          return scope.rotateIndex = index;
        };
      })(this);
      scope.clickShowingModel = (function(_this) {
        return function(index) {
          var rotateWaitingFlag;
          rotateWaitingFlag = true;
          changeShowingModel(index);
          return element.find('#' + showingModelList[index].element);
        };
      })(this);
      rotateShowingModel = (function(_this) {
        return function() {
          if (!_.isNumber(scope.rotateIndex) || scope.rotateIndex >= (showingModelList.length - 1)) {
            scope.rotateIndex = 0;
          } else {
            scope.rotateIndex += 1;
          }
          return changeShowingModel(scope.rotateIndex);
        };
      })(this);
      if (rotate) {
        return scope.setInterval = setInterval(rotateShowingModel, time);
      }
    };

    RotateShowingModelDirective.prototype.resize = function(scope) {};

    RotateShowingModelDirective.prototype.dispose = function(scope) {
      var _ref;
      if ((_ref = scope.sub3DStatus) != null) {
        _ref.dispose();
      }
      if (!_.isNull(scope.setInterval)) {
        return clearInterval(scope.setInterval);
      }
    };

    return RotateShowingModelDirective;

  })(base.BaseDirective);
  return exports = {
    RotateShowingModelDirective: RotateShowingModelDirective
  };
});
