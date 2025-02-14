// Generated by IcedCoffeeScript 108.0.13

/*
* File: user-groups-directive
* User: David
* Date: 2019/07/04
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var UserGroupsDirective, exports;
  UserGroupsDirective = (function(_super) {
    __extends(UserGroupsDirective, _super);

    function UserGroupsDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.loadGroup = __bind(this.loadGroup, this);
      this.loadUser = __bind(this.loadUser, this);
      this.show = __bind(this.show, this);
      this.id = "user-groups";
      UserGroupsDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.allUsers = [];
      this.allGroups = [];
      this.groupService = commonService.modelEngine.modelManager.getService("groups");
      this.userService = commonService.modelEngine.modelManager.getService("users");
    }

    UserGroupsDirective.prototype.setScope = function() {};

    UserGroupsDirective.prototype.setCSS = function() {
      return css;
    };

    UserGroupsDirective.prototype.setTemplate = function() {
      return view;
    };

    UserGroupsDirective.prototype.show = function(scope, element, attrs) {
      var delGroup, init, updateGroup, warpGroups;
      scope.forminfo = [
        [
          {
            title: "部门ID",
            edit: true,
            field: "groupId"
          }, {
            title: "部门名称",
            field: "groupName",
            edit: true
          }
        ], [
          {
            title: "负责人",
            field: "manager",
            type: "select",
            option: [],
            edit: true
          }, {
            title: "部门上级",
            type: "select",
            option: [],
            field: "superior",
            edit: true
          }
        ]
      ];
      scope.memberList = [];
      scope.groupInfo = {
        groupId: "",
        groupName: "",
        manager: "",
        superior: ""
      };
      scope.groupList = [];
      scope.userList = [];
      scope.selectNodeId = null;
      scope.showAddSelect = false;
      scope.addUser = "";
      updateGroup = (function(_this) {
        return function() {
          var obj, _group, _user;
          scope.addUser = "";
          scope.showAddSelect = false;
          if (scope.forminfo[0][0].edit && _.find(scope.groupList, function(d) {
            return d.value === scope.groupInfo.groupId;
          })) {
            M.toast({
              html: '部门ID已被占用！！'
            });
          } else if (scope.forminfo[0][0].edit && !_.find(scope.groupList, function(d) {
            return d.groupId === scope.groupInfo.groupId;
          })) {
            _user = _.find(_this.allUsers, function(d) {
              return d.user === scope.groupInfo.manager;
            });
            obj = {
              name: scope.groupInfo.groupName,
              manager: {
                id: scope.groupInfo.manager,
                name: _user != null ? _user.name : void 0
              },
              group: scope.groupInfo.groupId,
              parent: scope.groupInfo.superior,
              engineers: _.map(scope.memberList, function(d) {
                return {
                  id: d.value,
                  name: d.name,
                  title: "employee"
                };
              })
            };
            return _this.groupService.save(_.extend(obj, scope.project.getIds()), function(err, group) {
              if (err) {
                _this.display("错误提示：" + err);
                return;
              }
              _this.allGroups.unshift(group);
              return warpGroups(_this.allGroups);
            });
          } else if (!scope.forminfo[0][0].edit && scope.groupInfo.superior !== scope.groupInfo.groupId) {
            _group = _.find(_this.allGroups, function(d) {
              return d.group === scope.groupInfo.groupId;
            });
            _user = _.find(_this.allUsers, function(d) {
              return d.user === scope.groupInfo.manager;
            });
            obj = {
              _id: _group._id,
              name: scope.groupInfo.groupName,
              manager: {
                id: scope.groupInfo.manager,
                name: _user != null ? _user.name : void 0
              },
              group: scope.groupInfo.groupId,
              parent: scope.groupInfo.superior,
              engineers: _.map(scope.memberList, function(d) {
                return {
                  id: d.id,
                  name: d.name,
                  title: "employee"
                };
              })
            };
            return _this.groupService.update(_.extend(obj, scope.project.getIds()), function(err, group) {
              if (!group) {
                return console.warn("更新失败！！");
              }
              return warpGroups(_this.allGroups);
            });
          } else if (!scope.forminfo[0][0].edit && scope.groupInfo.superior === scope.groupInfo.groupId) {
            M.toast({
              html: '不能将部门自身作为部门上级！！'
            });
          }
        };
      })(this);
      delGroup = (function(_this) {
        return function() {
          var childGroups, _group;
          childGroups = _.find(_this.allGroups, function(d) {
            return d.parent === scope.groupInfo.groupId;
          });
          if (childGroups) {
            _this.display("温馨提示：该部门存在子部门，先删除子部门再删除此部门，请查证！");
            return;
          }
          _group = _.find(_this.allGroups, function(d) {
            return d.group === scope.groupInfo.groupId;
          });
          return _this.groupService.remove(_group, function(err, group) {
            var tmpGroups;
            if (!group) {
              return console.warn("删除失败！！");
            }
            tmpGroups = _.filter(_this.allGroups, function(item) {
              return item.group !== group[0].group;
            });
            _this.allGroups = tmpGroups;
            return warpGroups(_.filter(_this.allGroups, function(d) {
              return d.group !== _group.group;
            }));
          });
        };
      })(this);
      scope.btnClick = (function(_this) {
        return function(type) {
          if (type === 0) {
            if (scope.groupInfo.groupId === "" || scope.groupInfo.groupName === "") {
              M.toast({
                html: '部门ID/部门名称不可为空！！'
              });
              return;
            }
            return updateGroup();
          } else if (type === 1) {
            scope.memberList = [];
            scope.groupInfo = {
              groupId: _this.getUniqueName(scope.groupList, "depart", 'value', 1),
              groupName: _this.getUniqueName(scope.groupList, "部门", 'name', 1),
              manager: "",
              superior: ""
            };
            return scope.forminfo[0][0].edit = true;
          } else if (type === -1) {
            if (scope.groupInfo.groupId === "") {
              warpGroups(_this.allGroups);
              return;
            }
            return scope.prompt('温馨提示', '是否确定删除' + scope.groupInfo.groupName + "?", function(ok, comment) {
              if (!ok) {
                return;
              }
              return delGroup();
            });
          }
        };
      })(this);
      scope.selectGroup = (function(_this) {
        return function(index, item) {
          if (index !== scope.selectNodeId) {
            scope.forminfo[0][0].edit = false;
            scope.selectNodeId = index;
            scope.groupInfo = {
              groupId: item.value,
              groupName: item.name,
              manager: item.manager ? item.manager.id : "",
              superior: item.parent ? item.parent : ""
            };
            scope.memberList = item.member ? item.member : [];
            return scope.$applyAsync();
          }
        };
      })(this);
      scope.updateMember = (function(_this) {
        return function(index) {
          var addUserObj, hasUser;
          if (typeof index === "number") {
            scope.memberList = _.filter(scope.memberList, function(d) {
              return d.id !== scope.memberList[index].id;
            });
            scope.showAddSelect = false;
            return scope.$applyAsync();
          } else {
            hasUser = _.find(scope.memberList, function(d) {
              return d.id === index;
            });
            addUserObj = _.find(scope.userList, function(d) {
              return d.value === index;
            });
            if (!hasUser && addUserObj) {
              scope.memberList.push({
                name: addUserObj.name,
                title: "employee",
                id: addUserObj.value
              });
              scope.addUser = "";
              return scope.$applyAsync();
            } else {
              return M.toast({
                html: index === "" ? "不可选择空用户！！" : '请选择一个不在部门内的用户！！'
              });
            }
          }
        };
      })(this);
      warpGroups = (function(_this) {
        return function(groups) {
          var groupOption;
          groupOption = _.map(groups, function(d) {
            var parent;
            parent = null;
            if (_.has(d, "parent")) {
              parent = _.find(groups, function(m) {
                return m.group === d.parent;
              });
            }
            return {
              name: d.name,
              value: d.group,
              manager: d != null ? d.manager : void 0,
              parent: d != null ? d.parent : void 0,
              parentName: parent != null ? parent.name : void 0,
              member: d.engineers
            };
          });
          if (groupOption.length > 0 && _.isNull(scope.selectNodeId)) {
            scope.selectNodeId = 0;
            scope.forminfo[0][0].edit = false;
            scope.groupInfo = {
              groupId: groupOption[0].value,
              groupName: groupOption[0].name,
              manager: groupOption[0].manager ? groupOption[0].manager.id : "",
              superior: groupOption[0].parent ? groupOption[0].parent : ""
            };
            scope.memberList = groupOption[0].member;
          } else if (groupOption.length > 0 && typeof scope.selectNodeId === "number") {
            scope.forminfo[0][0].edit = false;
            scope.groupInfo = {
              groupId: groupOption[scope.selectNodeId].value,
              groupName: groupOption[scope.selectNodeId].name,
              manager: groupOption[scope.selectNodeId].manager ? groupOption[scope.selectNodeId].manager.id : "",
              superior: groupOption[scope.selectNodeId].parent ? groupOption[scope.selectNodeId].parent : ""
            };
            scope.memberList = groupOption[scope.selectNodeId].member;
          }
          scope.forminfo[1][1].option = groupOption;
          scope.groupList = groupOption;
          return scope.$applyAsync();
        };
      })(this);
      init = (function(_this) {
        return function() {
          _this.loadUser(function(users) {
            var userOption;
            userOption = _.map(users, function(d) {
              return {
                name: d.name,
                value: d.user
              };
            });
            scope.forminfo[1][0].option = userOption;
            scope.userList = userOption;
            return scope.$applyAsync();
          });
          return _this.loadGroup(function(groups) {
            return warpGroups(groups);
          });
        };
      })(this);
      return init();
    };

    UserGroupsDirective.prototype.loadUser = function(callback) {
      return this.userService.query({}, 'user name', (function(_this) {
        return function(err, userModels) {
          if (userModels) {
            _this.allUsers = userModels;
            return callback(userModels);
          }
        };
      })(this));
    };

    UserGroupsDirective.prototype.loadGroup = function(callback) {
      var filter;
      filter = {};
      filter.user = this.$routeParams.user;
      filter.project = this.$routeParams.project;
      return this.groupService.query(filter, 'group name manager parent engineers', (function(_this) {
        return function(err, groupModels) {
          if (groupModels) {
            _this.allGroups = groupModels;
            return callback(groupModels);
          }
        };
      })(this), true);
    };

    UserGroupsDirective.prototype.getUniqueName = function(items, prefix, property, index) {
      var item, name, _i, _len;
      if (index == null) {
        index = 1;
      }
      name = "" + prefix + "-" + index;
      if (items) {
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          if (item[property] === name) {
            return this.getUniqueName(items, prefix, property, index + 1);
          }
        }
      }
      return name;
    };

    UserGroupsDirective.prototype.resize = function(scope) {};

    UserGroupsDirective.prototype.dispose = function(scope) {};

    return UserGroupsDirective;

  })(base.BaseDirective);
  return exports = {
    UserGroupsDirective: UserGroupsDirective
  };
});
