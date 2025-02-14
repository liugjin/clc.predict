// Generated by IcedCoffeeScript 108.0.13

/*
* File: plugin-uploader-directive
* User: David
* Date: 2019/12/25
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var PluginUploaderDirective, exports;
  PluginUploaderDirective = (function(_super) {
    __extends(PluginUploaderDirective, _super);

    function PluginUploaderDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.link = __bind(this.link, this);
      this.id = "plugin-uploader";
      PluginUploaderDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    PluginUploaderDirective.prototype.setScope = function() {};

    PluginUploaderDirective.prototype.setCSS = function() {
      return css;
    };

    PluginUploaderDirective.prototype.setTemplate = function() {
      return view;
    };

    PluginUploaderDirective.prototype.link = function(scope, element, attrs) {
      var input;
      input = element.find('input[type="file"]');
      return input.bind('change', (function(_this) {
        return function(evt) {
          var file, params, url, zp, _ref, _ref1;
          file = (_ref = input[0]) != null ? (_ref1 = _ref.files) != null ? _ref1[0] : void 0 : void 0;
          evt.target.value = null;
          zp = new FormData;
          zp.append("file", file);
          url = scope.controller.$location.$$absUrl.substr(0, scope.controller.$location.$$absUrl.indexOf("#")) + "rpc/upload";
          params = {
            token: scope.controller.$rootScope.user.token
          };
          return _this.commonService.uploadService.$http({
            method: 'POST',
            url: url,
            data: zp,
            params: params,
            headers: {
              'Content-Type': void 0
            }
          }).then(function(res) {
            var _ref2;
            if (((_ref2 = res.data) != null ? _ref2.data : void 0) === "ok") {
              return _this.display("上传成功");
            } else {
              return _this.display("上传失败");
            }
          });
        };
      })(this));
    };

    PluginUploaderDirective.prototype.resize = function(scope) {};

    PluginUploaderDirective.prototype.dispose = function(scope) {};

    return PluginUploaderDirective;

  })(base.BaseDirective);
  return exports = {
    PluginUploaderDirective: PluginUploaderDirective
  };
});
