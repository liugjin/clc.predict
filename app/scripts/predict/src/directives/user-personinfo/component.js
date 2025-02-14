// Generated by IcedCoffeeScript 108.0.13

/*
* File: user-personinfo-directive
* User: David
* Date: 2018/12/18
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "tripledes"], function(base, css, view, _, moment, des) {
  var UserPersoninfoDirective, exports;
  UserPersoninfoDirective = (function(_super) {
    __extends(UserPersoninfoDirective, _super);

    function UserPersoninfoDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "user-personinfo";
      UserPersoninfoDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.userService = commonService.modelEngine.modelManager.getService("user");
      this.changePassword = commonService.modelEngine.modelManager.getService("changePassword");
      this.logonUser = commonService.$rootScope.user;
    }

    UserPersoninfoDirective.prototype.setScope = function() {};

    UserPersoninfoDirective.prototype.setCSS = function() {
      return css;
    };

    UserPersoninfoDirective.prototype.setTemplate = function() {
      return view;
    };

    UserPersoninfoDirective.prototype.show = function(scope, element, attrs) {
      scope.userObject = {};
      scope.showFlag = true;
      scope.oldPassword = "";
      scope.newPassword = "";
      scope.confirmPassword = "";
      scope.setting = setting;
      scope.prompt = function(title, message, callback) {
        scope.modal = {
          title: title,
          message: message,
          confirm: function(ok) {
            return typeof callback === "function" ? callback(ok, this.comment, this.password) : void 0;
          },
          preConfirm: function() {
            return typeof callback === "function" ? callback("preCommand", this.comment, this.password) : void 0;
          }
        };
        $('#user-manager-prompt-modal').modal('open');
      };
      this.userService.query({
        user: this.logonUser.user
      }, null, (function(_this) {
        return function(err, userDatas) {
          if (!err) {
            return scope.userObject = userDatas;
          }
        };
      })(this), true);
      scope.saveUser = (function(_this) {
        return function() {
          var r, userPhone;
          console.log(scope.userObject);
          userPhone = scope.userObject.phone;
          r = /^\+?[1-9][0-9]*$/;
          if (userPhone.length !== 11 || !r.test(userPhone)) {
            return _this.display('电话为空或格式不正确');
          } else {
            return _this.userService.save(scope.userObject, function(err, data) {
              return _this.display(err, '温馨提示：保存成功！');
            });
          }
        };
      })(this);
      scope.delUser = (function(_this) {
        return function() {
          $('#user-manager-prompt-modal').modal('open');
          return scope.prompt(function(ok, comment) {
            if (!ok) {
              return;
            }
            if (ok) {
              return _this.userService.remove(scope.userObject, function(err, data) {
                return _this.display(err, '温馨提示：删除成功！');
              });
            }
          });
        };
      })(this);
      scope.updatePassword = (function(_this) {
        return function() {
          var tmpPasswordObj, tmpUrl;
          if (_.isEmpty(scope.oldPassword)) {
            _this.display('温馨提示：请输入旧密码！');
            return;
          }
          if (_.isEmpty(scope.newPassword)) {
            _this.display('温馨提示：请输入新密码！');
            return;
          }
          if (scope.confirmPassword !== scope.newPassword) {
            _this.display('温馨提示：新密码与确认密码不一致，请重新输入新密码和确认密码！');
            return;
          }
          if (scope.confirmPassword === scope.oldPassword) {
            _this.display('温馨提示：新密码与旧密码一致，请重新输入！');
            return;
          }
          tmpPasswordObj = {
            user: scope.userObject.user,
            token: scope.userObject.token,
            oldPassword: _this.encrypt(scope.oldPassword, scope.userObject.user),
            password: _this.encrypt(scope.newPassword, scope.userObject.user)
          };
          tmpUrl = scope.setting.urls.changePassword.substr(0, scope.setting.urls.changePassword.indexOf("auth")) + "auth/changepassword";
          return _this.changePassword.postData(tmpUrl, tmpPasswordObj, function(err, retResult) {
            if (err) {
              return _this.display(null, '温馨提示：' + err);
            } else {
              _this.display(null, '温馨提示：修改密码成功！');
              scope.newPassword = '';
              scope.oldPassword = '';
              return scope.confirmPassword = '';
            }
          });
        };
      })(this);
      return scope.showUserInfo = (function(_this) {
        return function(refFlag) {
          return scope.showFlag = refFlag;
        };
      })(this);
    };

    UserPersoninfoDirective.prototype.encrypt = function(password, username) {
      if (!password || !username) {
        return;
      }
      return des.DES.encrypt(password, username).toString();
    };

    UserPersoninfoDirective.prototype.resize = function(scope) {};

    UserPersoninfoDirective.prototype.dispose = function(scope) {};

    return UserPersoninfoDirective;

  })(base.BaseDirective);
  return exports = {
    UserPersoninfoDirective: UserPersoninfoDirective
  };
});
