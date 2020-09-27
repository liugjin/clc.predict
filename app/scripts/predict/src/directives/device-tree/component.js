// Generated by IcedCoffeeScript 108.0.13

/*
* File: device-tree-directive
* User: David
* Date: 2018/11/22
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "fancytree"], function(base, css, view, _, moment, fct) {
  var DeviceTreeDirective, exports;
  DeviceTreeDirective = (function(_super) {
    __extends(DeviceTreeDirective, _super);

    function DeviceTreeDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      DeviceTreeDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.id = "device-tree";
    }

    DeviceTreeDirective.prototype.setScope = function() {};

    DeviceTreeDirective.prototype.setCSS = function() {
      return css;
    };

    DeviceTreeDirective.prototype.setTemplate = function() {
      return view;
    };

    DeviceTreeDirective.prototype.show = function(scope, element, attrs) {
      var join, root, roots, sources, _i, _len, _ref, _ref1;
      scope.search = "";
      scope.filter = (_ref = scope.parameters.filter) != null ? _ref : true;
      sources = [];
      join = (function(_this) {
        return function(station) {
          var result, ret, sta, _i, _len, _ref1;
          ret = {
            id: station.model.station,
            title: station.model.name,
            folder: true,
            level: "station",
            index: station.model.index
          };
          ret.icon = _this.getIcon(station.model.type);
          if (station.stations.length) {
            ret.children = [];
            _ref1 = station.stations;
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              sta = _ref1[_i];
              result = join(sta);
              ret.children.push(result);
            }
            ret.children = _.sortBy(ret.children, function(d) {
              return d.index;
            });
            ret.expanded = true;
          } else {
            ret.lazy = true;
            ret.expanded = false;
          }
          return ret;
        };
      })(this);
      roots = _.sortBy(_.filter(scope.project.stations.items, function(item) {
        if (item.model.station.charAt(0) !== "_") {
          return !item.model.parent;
        } else {
          return false;
        }
      }), function(d) {
        return d.model.index;
      });
      for (_i = 0, _len = roots.length; _i < _len; _i++) {
        root = roots[_i];
        sources.push(join(root));
      }
      element.find('.tree').fancytree({
        checkbox: (_ref1 = scope.parameters.checkbox) != null ? _ref1 : false,
        selectMode: 3,
        source: sources,
        extensions: ["filter"],
        filter: {
          autoApply: true,
          autoExpand: true,
          counter: true,
          fuzzy: false,
          hideExpandedCounter: true,
          hideExpanders: false,
          highlight: true,
          leavesOnly: false,
          nodata: true,
          mode: "hide"
        },
        lazyLoad: (function(_this) {
          return function(event, data) {
            var arr, station;
            arr = [];
            station = _.find(scope.project.stations.items, function(item) {
              return item.model.station === data.node.data.id && item.model.station.charAt(0) !== "_";
            });
            return data.result = $.Deferred(function(dtd) {
              arr = [];
              return station != null ? station.loadEquipments({}, null, function(err, equips) {
                var equip, _j, _len1;
                for (_j = 0, _len1 = equips.length; _j < _len1; _j++) {
                  equip = equips[_j];
                  if (equip.model.type.substr(0, 1) !== "_") {
                    arr.push({
                      id: equip.model.equipment,
                      title: equip.model.name,
                      icon: _this.getIcon(equip.model.type),
                      station: equip.station.model.station,
                      level: "equipment"
                    });
                  }
                }
                return dtd.resolve(arr);
              }) : void 0;
            });
          };
        })(this),
        activate: (function(_this) {
          return function(event, data) {
            var selectNode;
            selectNode = data.node;
            return _this.publishEventBus("selectEquip", selectNode.data);
          };
        })(this),
        beforeSelect: (function(_this) {
          return function(event, data) {
            var a, button, checkbox, item, parstations, _j, _k, _len1, _len2, _ref2, _ref3, _ref4, _results;
            parstations = [];
            _ref2 = scope.project.stations.items;
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              item = _ref2[_j];
              if (item.stations.length) {
                parstations.push(item.model.station);
              }
            }
            a = event.originalEvent.target;
            if (data.node.data.level === 'station' && !data.node.children) {
              $(a).prev().trigger('click');
              return setTimeout(function() {
                $(a).prev().trigger('click');
                $(a).trigger('click');
                return $(a).trigger('click');
              }, 100);
            } else if (data.node.data.level === 'station' && (_ref3 = data.node.data.id, __indexOf.call(parstations, _ref3) >= 0)) {
              _ref4 = data.node.children;
              _results = [];
              for (_k = 0, _len2 = _ref4.length; _k < _len2; _k++) {
                item = _ref4[_k];
                button = item.span.children[0];
                checkbox = item.span.children[1];
                $(button).trigger("click");
                _results.push((function(button, checkbox) {
                  return setTimeout(function() {
                    $(button).trigger('click');
                    $(checkbox).trigger('click');
                    return $(checkbox).trigger('click');
                  }, 1000);
                })(button, checkbox));
              }
              return _results;
            }
          };
        })(this),
        select: (function(_this) {
          return function(event, data) {
            var node, selectNodes, selects, _j, _len1;
            selects = [];
            selectNodes = data.tree.getSelectedNodes();
            for (_j = 0, _len1 = selectNodes.length; _j < _len1; _j++) {
              node = selectNodes[_j];
              selects.push(node.data);
            }
            return _this.publishEventBus("checkEquips", selects);
          };
        })(this)
      });
      scope.filterTree = function() {
        var filterFunc, match, opts, tree;
        tree = $.ui.fancytree.getTree();
        opts = {
          "autoApply": true,
          "autoExpand": true,
          "fuzzy": false,
          "hideExpanders": false,
          "highlight": true,
          "leavesOnly": false,
          "nodata": false
        };
        filterFunc = tree.filterBranches;
        match = scope.search;
        return filterFunc.call(tree, match, opts);
      };
      return scope.clearSearch = function() {
        return scope.search = "";
      };
    };

    DeviceTreeDirective.prototype.getIcon = function(type) {
      return {
        html: '<img src="' + this.getComponentPath("icons/" + type + ".svg") + '" class="icon"/>'
      };
    };

    DeviceTreeDirective.prototype.resize = function(scope) {};

    DeviceTreeDirective.prototype.dispose = function(scope) {};

    return DeviceTreeDirective;

  })(base.BaseDirective);
  return exports = {
    DeviceTreeDirective: DeviceTreeDirective
  };
});
