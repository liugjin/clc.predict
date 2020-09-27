// Generated by IcedCoffeeScript 108.0.13

/*
* File: inventory-manage-directive
* User: bingo
* Date: 2018/11/20
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var InventoryListDirective, exports;
  InventoryListDirective = (function(_super) {
    __extends(InventoryListDirective, _super);

    function InventoryListDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.getAllStations = __bind(this.getAllStations, this);
      this.show = __bind(this.show, this);
      this.id = "inventory-list";
      InventoryListDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.allInventoryStations = [];
    }

    InventoryListDirective.prototype.setScope = function() {};

    InventoryListDirective.prototype.setCSS = function() {
      return css;
    };

    InventoryListDirective.prototype.setTemplate = function() {
      return view;
    };

    InventoryListDirective.prototype.show = function($scope, element, attrs) {
      var getEquipNumber, getNextName, getStationEquipTypes, input, loadAllUsers, loadEquipsByAdd, loadStatisticByEquipmentTypes, preview, processTypes, selectType, setEquipmentData, settingEquipSampleUnits, spliceStatusFormat, uploadImage;
      element.css("display", "block");
      $scope.setting = setting;
      $scope.jumpImg = this.getComponentPath('image/next.png');
      $scope.currentType = null;
      $scope.equipTypes = null;
      $scope.view = true;
      $scope.detail = false;
      $scope.editShow = false;
      $scope.assetShow = false;
      $scope.addShow = true;
      $scope.add = false;
      $scope.viewName = '列表';
      $scope.pageIndex = 1;
      $scope.pageItems = 12;
      preview = element.find('.img-preview');
      input = element.find('input[type="file"].img-input');
      $scope.dir = setting.urls.uploadUrl;
      $scope.accept = "image/*";
      $scope.showLink = false;
      $scope.addImg = this.getComponentPath('image/add.svg');
      $scope.viewImg = this.getComponentPath('image/view.svg');
      $scope.backImg = this.getComponentPath('image/back.svg');
      $scope.detailBlueImg = this.getComponentPath('image/detail-blue.svg');
      $scope.editBlueImg = this.getComponentPath('image/edit-blue.svg');
      $scope.saveImg = this.getComponentPath('image/save-blue.svg');
      $scope.detailGreenImg = this.getComponentPath('image/detail-green.svg');
      $scope.editGreenImg = this.getComponentPath('image/edit-green.svg');
      $scope.deleteGreenImg = this.getComponentPath('image/delete-green.svg');
      $scope.copyGreenImg = this.getComponentPath('image/copy-green.svg');
      $scope.uploadImg = this.getComponentPath('image/upload.svg');
      $scope.deleteImg = this.getComponentPath('image/delete.svg');
      $scope.linkImg = this.getComponentPath('image/link.svg');
      $scope.downImg = this.getComponentPath('image/download.svg');
      $scope.noEquipImg = this.getComponentPath('image/no-equip.svg');
      $scope.project.loadEquipmentTemplates({}, null);
      $scope.project.loadStations(null, (function(_this) {
        return function(err, stations) {
          var dataCenters;
          dataCenters = _.filter(stations, function(sta) {
            return (sta.model.parent === null || sta.model.parent === "") && sta.model.station.charAt(0) !== "_";
          });
          $scope.predicts = dataCenters;
          $scope.stations = dataCenters;
          $scope.station = dataCenters[0];
          return $scope.parents = [];
        };
      })(this));
      $scope.selectStation = (function(_this) {
        return function(station) {
          return $scope.station = station;
        };
      })(this);
      $scope.selectChild = (function(_this) {
        return function(station) {
          $scope.stations = $scope.station.stations;
          $scope.parents.push($scope.station);
          return $scope.station = station;
        };
      })(this);
      $scope.selectParent = (function(_this) {
        return function(station) {
          var index, _ref, _ref1;
          index = $scope.parents.indexOf(station);
          $scope.parents.splice(index, $scope.parents.length - index);
          $scope.station = station;
          return $scope.stations = (_ref = (_ref1 = station.parentStation) != null ? _ref1.stations : void 0) != null ? _ref : $scope.predicts;
        };
      })(this);
      preview.bind('click', (function(_this) {
        return function() {
          return input.click();
        };
      })(this));
      input.bind('change', (function(_this) {
        return function(evt) {
          var _ref, _ref1;
          if (_this.commonService.uploadService) {
            uploadImage((_ref = input[0]) != null ? (_ref1 = _ref.files) != null ? _ref1[0] : void 0 : void 0);
          }
          evt.target.value = null;
        };
      })(this));
      uploadImage = (function(_this) {
        return function(file) {
          var url;
          if (!file) {
            return;
          }
          url = "" + $scope.dir + "/" + file.name;
          _this.commonService.uploadService.upload(file, $scope.filename, url, function(err, resource) {
            if (err) {
              return console.log(err);
            } else {
              return $scope.equipment.model.image = "" + resource.resource + resource.extension + "?" + (new Date().getTime());
            }
          }, function(progress) {
            return $scope.progress = progress * 100;
          });
        };
      })(this);
      $scope["delete"] = (function(_this) {
        return function() {
          $scope.equipment.model.image = "";
        };
      })(this);
      loadAllUsers = (function(_this) {
        return function() {
          var fields, filter, userService;
          userService = _this.commonService.modelEngine.modelManager.getService('users');
          filter = {};
          fields = null;
          return userService.query(filter, fields, function(err, data) {
            if (!err) {
              return $scope.userMsg = data;
            }
          });
        };
      })(this);
      $scope.$watch('station', (function(_this) {
        return function(station) {
          $scope.detail = false;
          $scope.editShow = false;
          $scope.assetShow = false;
          $scope.addShow = true;
          $scope.add = false;
          $scope.currentType = null;
          $scope.childStations = [];
          loadStatisticByEquipmentTypes();
          loadAllUsers();
          if (!$scope.subscribeReturnList) {
            if (typeof $scope.subscribeReturnList === "function") {
              $scope.subscribeReturnList(dispose());
            }
            return $scope.subscribeReturnList = _this.subscribeEventBus('backList', function(msg) {
              $scope.editShow = false;
              $scope.assetShow = false;
              $scope.addShow = true;
              return loadStatisticByEquipmentTypes();
            });
          }
        };
      })(this));
      loadStatisticByEquipmentTypes = (function(_this) {
        return function() {
          return getStationEquipTypes(function(equipTypeDatas) {
            var equipTypeDataItem, it, item, j, stationType, _i, _len, _ref;
            stationType = {
              statistic: {}
            };
            for (_i = 0, _len = equipTypeDatas.length; _i < _len; _i++) {
              equipTypeDataItem = equipTypeDatas[_i];
              _ref = equipTypeDataItem.statistic;
              for (j in _ref) {
                item = _ref[j];
                it = _.findWhere(stationType.statistic, {
                  type: item.type
                });
                if (it) {
                  it.count = it.count + item.count;
                } else {
                  stationType.statistic[item.type] = item;
                }
              }
            }
            return processTypes(stationType, true);
          });
        };
      })(this);
      getStationEquipTypes = (function(_this) {
        return function(callback) {
          var allEquipModels, allInventoryStationsCount, allInventoryStationsLen, stationObj, _i, _len, _ref, _results;
          _this.allInventoryStations = [];
          _this.getAllStations($scope, $scope.station.model.station);
          allInventoryStationsLen = _this.allInventoryStations.length;
          allInventoryStationsCount = 0;
          allEquipModels = [];
          _ref = _this.allInventoryStations;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            stationObj = _ref[_i];
            _results.push(stationObj.loadStatisticByEquipmentTypes(function(err, mod) {
              allEquipModels.push(mod);
              allInventoryStationsCount++;
              if (allInventoryStationsCount === allInventoryStationsLen) {
                return typeof callback === "function" ? callback(allEquipModels) : void 0;
              }
            }, true));
          }
          return _results;
        };
      })(this);
      processTypes = (function(_this) {
        return function(data, refresh) {
          var key, types, typesArr, value, _ref;
          if (!(data != null ? data.statistic : void 0)) {
            return;
          }
          types = [];
          _ref = data.statistic;
          for (key in _ref) {
            value = _ref[key];
            if (value.type[0] !== '_') {
              types.push(value);
            }
          }
          _.map(types, function(type) {
            var currentType;
            currentType = _.find($scope.project.dictionary.equipmenttypes.items, function(item) {
              return item.model.type === type.type;
            });
            if (currentType.model.image) {
              return type.image = currentType.model.image;
            }
          });
          $scope.equipTypes = types;
          typesArr = _.filter($scope.equipTypes, function(type) {
            return type.count !== 0 && type.type !== 'KnowledgeDepot';
          });
          if (!$scope.currentType) {
            $scope.currentType = _.find(typesArr, function(item) {
              return item.type === 'motor';
            });
          }
          return selectType($scope.currentType.type, null, refresh);
        };
      })(this);
      selectType = (function(_this) {
        return function(type, callback, refresh) {
          var getStationEquipment;
          if (!type) {
            return;
          }
          $scope.equipments = [];
          getStationEquipment = function(station, callback) {
            var sta, _i, _len, _ref;
            _ref = station.stations;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              sta = _ref[_i];
              getStationEquipment(sta, callback);
            }
            return _this.commonService.loadEquipmentsByType(station, type, function(err, mods) {
              return typeof callback === "function" ? callback(mods) : void 0;
            }, refresh);
          };
          return getStationEquipment($scope.station, function(equips) {
            var diff, equip, ownerobj, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
            diff = _.difference(equips, $scope.equipments);
            $scope.equipments = $scope.equipments.concat(diff);
            $scope.$applyAsync();
            _results = [];
            for (_i = 0, _len = equips.length; _i < _len; _i++) {
              equip = equips[_i];
              ownerobj = _.find($scope.userMsg, function(userobj) {
                return userobj.user === equip.model.owner;
              });
              equip.model.owner = ownerobj != null ? ownerobj.name : void 0;
              equip.loadProperties();
              equip.model.typeName = (_ref = _.find($scope.project.dictionary.equipmenttypes.items, function(type) {
                return type.key === equip.model.type;
              })) != null ? _ref.model.name : void 0;
              equip.model.templateName = (_ref1 = _.find($scope.project.equipmentTemplates.items, function(template) {
                return template.model.type === equip.model.type && template.model.template === equip.model.template;
              })) != null ? _ref1.model.name : void 0;
              equip.model.vendorName = (_ref2 = _.find($scope.project.dictionary.vendors.items, function(vendor) {
                return vendor.key === equip.model.vendor;
              })) != null ? _ref2.model.name : void 0;
              _results.push(equip.model.stationName = (_ref3 = _.find($scope.project.stations.items, function(station) {
                return station.model.station === equip.model.station;
              })) != null ? _ref3.model.name : void 0);
            }
            return _results;
          });
        };
      })(this);
      $scope.selectEquipType = (function(_this) {
        return function(type) {
          $scope.pageIndex = 1;
          $scope.detail = false;
          $scope.editShow = false;
          $scope.assetShow = false;
          $scope.addShow = true;
          $scope.currentType = type;
          return selectType($scope.currentType.type, null, false);
        };
      })(this);
      $scope.selectEquip = (function(_this) {
        return function(equipment) {
          $scope.equipment = equipment;
          return setEquipmentData();
        };
      })(this);
      setEquipmentData = (function(_this) {
        return function() {
          return _.map($scope.equipment.properties.items, function(item) {
            var install, life, lt, statusArr, _i, _len;
            if (item.model.property === 'status') {
              $scope.equipment.model.status = item.value;
              statusArr = item.model.format.split(',');
              for (_i = 0, _len = statusArr.length; _i < _len; _i++) {
                lt = statusArr[_i];
                if (lt.split(":")[0] === item.value || lt.split(":")[1] === item.value) {
                  $scope.equipment.model.statusName = lt.split(":")[1];
                  item.model.value = lt.split(":")[1];
                }
              }
            }
            if (item.model.property === 'install-date') {
              life = _.find($scope.equipment.properties.items, function(item) {
                return item.model.property === 'life';
              });
              if ((life != null ? life.value : void 0) && (item != null ? item.value : void 0)) {
                $scope.equipment.model.remainDate = (life != null ? life.value : void 0) - moment().diff(item != null ? item.value : void 0, 'months');
              } else {
                $scope.equipment.model.remainDate = '-';
              }
            }
            if (item.model.property === 'guarantee-month') {
              if (item.value) {
                install = _.find($scope.equipment.properties.items, function(item) {
                  return item.model.property === 'install-date';
                });
                if ((item != null ? item.value : void 0) && (install != null ? install.value : void 0)) {
                  $scope.equipment.model.repairDate = item.value - moment().diff(install.value, 'months') % item.value;
                } else {
                  $scope.equipment.model.repairDate = '-';
                }
              } else {
                $scope.equipment.model.repairDate = 0;
              }
            }
            if (_.isNaN($scope.equipment.model.remainDate)) {
              $scope.equipment.model.remainDate = '-';
            }
            if (_.isNaN($scope.equipment.model.repairDate)) {
              return $scope.equipment.model.repairDate = '-';
            }
          });
        };
      })(this);
      $scope.importAssets = (function(_this) {
        return function() {
          $scope.editShow = false;
          $scope.assetShow = true;
          return $scope.addShow = false;
        };
      })(this);
      $scope.switchView = (function(_this) {
        return function() {
          $scope.view = !$scope.view;
          $scope.pageIndex = 1;
          if ($scope.view) {
            $scope.pageItems = 12;
            return $scope.viewName = '列表';
          } else {
            $scope.pageItems = 8;
            return $scope.viewName = '视图';
          }
        };
      })(this);
      $scope.selectPage = (function(_this) {
        return function(page) {
          return $scope.pageIndex = page;
        };
      })(this);
      $scope.imgString = (function(_this) {
        return function(templateId) {
          var template, url;
          url = "";
          template = _.find($scope.project.equipmentTemplates.items, function(item) {
            return item.model.template === templateId;
          });
          if (template && template.model.image) {
            url = "url('" + $scope.setting.urls.uploadUrl + "/" + template.model.image + "')";
          } else {
            url = "url('" + $scope.noEquipImg + "')";
          }
          return url;
        };
      })(this);
      $scope.backList = (function(_this) {
        return function() {
          $scope.equipment = null;
          $scope.detail = false;
          $scope.editShow = false;
          $scope.assetShow = false;
          $scope.addShow = true;
          $scope.add = false;
          $scope.edit = false;
          return loadStatisticByEquipmentTypes();
        };
      })(this);
      $scope.saveEquipment = (function(_this) {
        return function() {
          return $scope.equipment.save(function(err, model) {
            return loadStatisticByEquipmentTypes();
          });
        };
      })(this);
      $scope.saveEquipment = (function(_this) {
        return function(obj) {
          return $scope.equipment.save(function(err, model) {
            return loadStatisticByEquipmentTypes();
          });
        };
      })(this);
      getNextName = function(name, defaultName) {
        var name2;
        if (defaultName == null) {
          defaultName = "";
        }
        if (!name) {
          return defaultName;
        }
        name2 = name.replace(/(\d*$)/, function(m, p1) {
          var num;
          return num = p1 ? parseInt(p1) + 1 : '-0';
        });
        return name2;
      };
      $scope.copyEquipment = (function(_this) {
        return function(equip) {
          var model, _ref;
          if (!equip) {
            return;
          }
          $scope.edit = true;
          $scope.add = true;
          $scope.editShow = true;
          $scope.assetShow = false;
          $scope.addShow = false;
          model = {
            equipment: getNextName(equip.model.equipment),
            name: getNextName(equip.model.name),
            type: equip.model.type,
            template: equip.model.template,
            vendor: equip.model.vendor,
            owner: equip.model.owner,
            image: equip.model.image,
            desc: equip.model.desc
          };
          $scope.equipment = (_ref = $scope.station) != null ? _ref.createEquipment(model, equip != null ? equip.parentElement : void 0) : void 0;
          $scope.equipment.propertyValues = angular.copy(equip.propertyValues);
          $scope.equipment.sampleUnits = angular.copy(equip.sampleUnits);
          $scope.settingEquipId();
          $scope.$applyAsync();
          return $scope.equipment;
        };
      })(this);
      $scope.addEquipment = (function(_this) {
        return function() {
          $scope.add = true;
          $scope.edit = true;
          $scope.editShow = true;
          $scope.assetShow = false;
          $scope.addShow = false;
          $scope.equipment = $scope.station.createEquipment(null);
          return $scope.equipment.model.type = $scope.currentType.type;
        };
      })(this);
      $scope.stationChange = (function(_this) {
        return function() {
          return $scope.settingEquipId();
        };
      })(this);
      $scope.equipTypeChange = (function(_this) {
        return function() {
          $scope.currentType = _.find($scope.equipTypes, function(type) {
            return type.type === $scope.equipment.model.type;
          });
          return $scope.settingEquipId();
        };
      })(this);
      $scope.equipVendorChange = (function(_this) {
        return function() {
          return $scope.settingEquipId();
        };
      })(this);
      $scope.equipTemplateChange = (function(_this) {
        return function() {
          return $scope.settingEquipId();
        };
      })(this);
      $scope.settingEquipId = (function(_this) {
        return function() {
          if (!$scope.equipment.model.station || !$scope.equipment.model.type || !$scope.equipment.model.vendor || !$scope.equipment.model.template) {
            return;
          }
          return $scope.equipment.loadProperties(null, function(err, properties) {
            var equipmentTemplate, name, template;
            template = $scope.equipment.model.template;
            equipmentTemplate = _.find($scope.project.equipmentTemplates.items, function(item) {
              return item.model.template === template;
            });
            if (equipmentTemplate != null) {
              equipmentTemplate.loadProperties(null, function(err, result) {
                _.each(result, function(item) {
                  if (item.model.dataType === 'date' || item.model.dataType === 'time' || item.model.dataType === 'datetime') {
                    item.model.value = moment(item.model.value).toDate();
                  }
                  return item.value = item.model.value;
                });
                return $scope.equipment._properties = result;
              });
            }
            $scope.equipment._sampleUnits = equipmentTemplate != null ? equipmentTemplate.model.sampleUnits : void 0;
            name = equipmentTemplate != null ? equipmentTemplate.model.name.replace(/模板/, '') : void 0;
            return loadEquipsByAdd(function(num) {
              var equipID, equipName;
              equipID = $scope.equipment.model.type + '-' + $scope.equipment.model.template + '-' + num;
              equipName = name + '-' + num;
              $scope.equipment.model.equipment = equipID;
              $scope.equipment.model.name = equipName;
              return settingEquipSampleUnits();
            });
          });
        };
      })(this);
      loadEquipsByAdd = (function(_this) {
        return function(callback) {
          var filter, station;
          station = _.find($scope.project.stations.items, function(station) {
            return station.model.station === $scope.equipment.model.station;
          });
          filter = {
            user: $scope.equipment.model.user,
            project: $scope.equipment.model.project,
            type: $scope.equipment.model.type,
            template: $scope.equipment.model.template
          };
          return station.loadEquipments(filter, null, function(err, equips) {
            if (err) {
              return;
            }
            return typeof callback === "function" ? callback(getEquipNumber(equips)) : void 0;
          }, true);
        };
      })(this);
      getEquipNumber = (function(_this) {
        return function(equips) {
          var i, result;
          i = 0;
          _.map(equips, function(equip) {
            var arr, num, str;
            arr = equip.model.equipment.split('-');
            str = arr[arr.length - 1];
            num = str.replace(/[^0-9]/ig, "");
            if ((num - i) > 0) {
              return i = num;
            }
          });
          i++;
          result = i;
          return result;
        };
      })(this);
      settingEquipSampleUnits = (function(_this) {
        return function() {
          var mu, su;
          mu = 'mu-' + $scope.equipment.model.user + '.' + $scope.equipment.model.project + '.' + $scope.equipment.model.station;
          su = 'su-' + $scope.equipment.model.equipment;
          $scope.equipment.model.sampleUnits = [];
          _.each($scope.equipment._sampleUnits, function(sampleUnits) {
            var sample;
            sampleUnits.value = mu + '/' + su;
            sample = {};
            sample.id = sampleUnits.id;
            sample.value = mu + '/' + su;
            $scope.equipment.model.sampleUnits.push(sample);
            return $scope.equipment.sampleUnits[sampleUnits.id] = sampleUnits;
          });
        };
      })(this);
      $scope.saveEquipmentGroups = (function(_this) {
        return function() {
          var prop, tmpProps, _i, _len, _ref;
          $scope.add = false;
          $scope.editShow = false;
          $scope.assetShow = false;
          $scope.addShow = true;
          $scope.detail = false;
          $scope.currentType = _.find($scope.equipTypes, function(type) {
            return type.type === $scope.equipment.model.type;
          });
          tmpProps = [];
          _ref = $scope.equipment.properties.items;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            prop = _ref[_i];
            tmpProps.push({
              id: prop.model.property,
              value: prop.value
            });
          }
          $scope.equipment.propertyValues = tmpProps;
          return $scope.saveEquipment();
        };
      })(this);
      $scope.deleteEquip = (function(_this) {
        return function(equip) {
          var message, title;
          $scope.equipment = equip;
          title = "删除设备确认: " + $scope.project.model.name + "/" + $scope.station.model.name + "/" + $scope.equipment.model.name;
          message = "请确认是否删除设备: " + $scope.project.model.name + "/" + $scope.station.model.name + "/" + $scope.equipment.model.name + "？删除后设备和数据将从系统中移除不可恢复！";
          return $scope.prompt(title, message, function(ok) {
            if (!ok) {
              return;
            }
            return $scope.equipment.remove(function(err, model) {
              return loadStatisticByEquipmentTypes();
            });
          });
        };
      })(this);
      $scope.editData = (function(_this) {
        return function(equipment) {
          var _ref;
          $scope.edit = true;
          $scope.add = false;
          $scope.editShow = true;
          $scope.assetShow = false;
          $scope.addShow = false;
          if (equipment) {
            $scope.equipment = equipment;
            if ((_ref = $scope.equipment.model) != null) {
              _ref.sampleVals = angular.copy(equipment.sampleUnits);
            }
          }
          return setEquipmentData();
        };
      })(this);
      $scope.saveValue = (function(_this) {
        return function(value) {
          return $scope.oldValue = value;
        };
      })(this);
      $scope.checkValue = (function(_this) {
        return function(value) {
          if ($scope.oldValue === value) {

          } else {
            return $scope.saveEquipment();
          }
        };
      })(this);
      $scope.$watch('equipment.model.image', (function(_this) {
        return function() {
          if ($scope.editShow && !$scope.add) {
            return $scope.saveEquipment();
          }
        };
      })(this));
      $scope.stationCheck = (function(_this) {
        return function() {
          if ($scope.equipment.model.station) {
            return $scope.saveEquipment();
          }
        };
      })(this);
      spliceStatusFormat = (function(_this) {
        return function(equip) {
          var i, j, key, str1, strs, value, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
          strs = {};
          if (equip) {
            _ref1 = (_ref = equip.properties) != null ? _ref.items : void 0;
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              i = _ref1[_i];
              if (((_ref2 = i.model) != null ? _ref2.dataType : void 0) === 'enum') {
                str1 = (_ref3 = i.model) != null ? _ref3.format.split(',') : void 0;
                for (_j = 0, _len1 = str1.length; _j < _len1; _j++) {
                  j = str1[_j];
                  key = j.split(':')[0];
                  value = j.split(':')[1];
                  strs[key] = value;
                }
                i.model.newformats = strs;
              }
            }
            return equip;
          } else {
            return equip;
          }
        };
      })(this);
      $scope.lookData2 = (function(_this) {
        return function(equipment) {
          return window.location.hash = "#/device-details/" + $scope.project.model.user + "/" + $scope.project.model.project + "/" + equipment.model.station + "/" + equipment.model.equipment;
        };
      })(this);
      $scope.lookData3 = (function(_this) {
        return function(equipment) {
          return window.location.hash = "#/monitoring/" + $scope.project.model.user + "/" + $scope.project.model.project + "?&station=" + equipment.model.station + "&equipment=" + equipment.model.equipment + "&type=" + equipment.model.type;
        };
      })(this);
      $scope.lookData = (function(_this) {
        return function(equipment) {
          var _ref;
          $scope.editShow = false;
          $scope.assetShow = false;
          $scope.addShow = true;
          $scope.detail = true;
          $scope.edit = false;
          if (equipment) {
            spliceStatusFormat(equipment);
            $scope.equipment = equipment;
            if ((_ref = $scope.equipment.model) != null) {
              _ref.sampleVals = angular.copy(equipment.sampleUnits);
            }
          }
          return setEquipmentData();
        };
      })(this);
      $scope.filterTypes = (function(_this) {
        return function() {
          return function(type) {
            return type.count !== 0 && type.type !== 'KnowledgeDepot';
          };
        };
      })(this);
      $scope.filterEquipment = (function(_this) {
        return function() {
          return function(equipment) {
            var text, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
            text = (_ref = $scope.searchLists) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = equipment.model.equipment) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = equipment.model.name) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref3 = equipment.model.tag) != null ? _ref3.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref4 = equipment.model.typeName) != null ? _ref4.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref5 = equipment.model.stationName) != null ? _ref5.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref6 = equipment.model.vendorName) != null ? _ref6.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          };
        };
      })(this);
      $scope.filterEquipmentItem = (function(_this) {
        return function() {
          var items, pageCount, result, _i, _results;
          if (!$scope.equipments) {
            return;
          }
          items = [];
          items = _.filter($scope.equipments, function(equipment) {
            var text, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
            text = (_ref = $scope.searchLists) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = equipment.model.equipment) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = equipment.model.name) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref3 = equipment.model.tag) != null ? _ref3.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref4 = equipment.model.typeName) != null ? _ref4.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref5 = equipment.model.stationName) != null ? _ref5.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref6 = equipment.model.vendorName) != null ? _ref6.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          });
          pageCount = Math.ceil(items.length / $scope.pageItems);
          result = {
            page: 1,
            pageCount: pageCount,
            pages: (function() {
              _results = [];
              for (var _i = 1; 1 <= pageCount ? _i <= pageCount : _i >= pageCount; 1 <= pageCount ? _i++ : _i--){ _results.push(_i); }
              return _results;
            }).apply(this),
            items: items.length
          };
          return result;
        };
      })(this);
      $scope.limitToEquipment = (function(_this) {
        return function() {
          var aa, result;
          if ($scope.filterEquipmentItem() && $scope.filterEquipmentItem().pageCount === $scope.pageIndex) {
            aa = $scope.filterEquipmentItem().items % $scope.pageItems;
            result = -(aa === 0 ? $scope.pageItems : aa);
          } else {
            result = -$scope.pageItems;
          }
          return result;
        };
      })(this);
      $scope.filterProperties = function() {
        return (function(_this) {
          return function(item) {
            var text, _ref, _ref1, _ref2;
            if (item.model.dataType === "json" || item.model.dataType === "script" || item.model.dataType === "html" || item.model.dataType === "image" || item.model.visible === false) {
              return false;
            }
            text = (_ref = $scope.searchDetail) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = item.model.name) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = item.model.property) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          };
        })(this);
      };
      $scope.filterEditItems1 = (function(_this) {
        return function() {
          return function(item) {
            if (item.model.dataType === "json" || item.model.dataType === "script" || item.model.dataType === "html" || item.model.visible === false) {
              return false;
            }
            if (item.model.property === 'production-time' || item.model.name === '生产日期') {
              return true;
            }
            if (item.model.property === 'buy-date' || item.model.name === '购买日期') {
              return true;
            }
            if (item.model.property === 'install-date' || item.model.name === '安装日期') {
              return true;
            }
            return false;
          };
        };
      })(this);
      $scope.filterEditItems2 = (function(_this) {
        return function() {
          return function(item) {
            var text, _ref, _ref1, _ref2;
            if (item.model.dataType === "json" || item.model.dataType === "script" || item.model.dataType === "html" || item.model.visible === false) {
              return false;
            }
            if (item.model.property === 'production-time' || item.model.name === '生产日期') {
              return false;
            }
            if (item.model.property === 'buy-date' || item.model.name === '购买日期') {
              return false;
            }
            if (item.model.property === 'install-date' || item.model.name === '安装日期') {
              return false;
            }
            text = (_ref = $scope.searchEdit) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = item.model.name) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = item.model.property) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          };
        };
      })(this);
      return $scope.filterEquipmentTemplate = (function(_this) {
        return function() {
          return function(template) {
            var model;
            if (!$scope.equipment) {
              return false;
            }
            model = $scope.equipment.model;
            return template.model.type === model.type && template.model.vendor === model.vendor;
          };
        };
      })(this);
    };

    InventoryListDirective.prototype.getAllStations = function(refScope, refStation) {
      var childStations, childStationsItem, stationResult, stationResultItem, _i, _j, _len, _len1;
      stationResult = _.filter(refScope.project.stations.items, function(stationItem) {
        return stationItem.model.station === refStation;
      });
      for (_i = 0, _len = stationResult.length; _i < _len; _i++) {
        stationResultItem = stationResult[_i];
        childStations = _.filter(refScope.project.stations.items, function(stationItem) {
          return stationItem.model.parent === refStation;
        });
        this.allInventoryStations.push(stationResultItem);
        if (!childStations) {
          return;
        }
        for (_j = 0, _len1 = childStations.length; _j < _len1; _j++) {
          childStationsItem = childStations[_j];
          this.getAllStations(refScope, childStationsItem.model.station);
        }
      }
    };

    InventoryListDirective.prototype.resize = function($scope) {};

    InventoryListDirective.prototype.dispose = function($scope) {
      return typeof $scope.subscribeReturnList === "function" ? $scope.subscribeReturnList(dispose()) : void 0;
    };

    return InventoryListDirective;

  })(base.BaseDirective);
  return exports = {
    InventoryListDirective: InventoryListDirective
  };
});
