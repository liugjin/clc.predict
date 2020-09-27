`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class NotificationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "notification"
      @equipments = {} #按站点取设备
    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.cates = [
        {
          name: '邮件'
          type: 'email'
          img: 'image/yj.jpg'
        }
        {
          name: '微信'
          type: 'wechat'
          img:'image/yj.jpg'
        }
        {
          name: '云短信'
          type: 'cloudsms'
          img: 'image/yj.jpg'
        }
      ]
      scope.cate = scope.cates[0].type
      scope.equipments = []
      rule = {}
      rule.allEventPhases = true
      rule.allEventTypes = true
      #########################--station--#########################
      stations = _.map scope.project.stations.items,(s) =>
        return {name:s.model.name,station:s.model.station,checked:false}
      scope.stations = stations
      scope.station_all_select = false
      scope.station_all_select_chan = () =>
        if scope.station_all_select
          _.each scope.stations,(u) ->
            u.checked = true
        else
          _.each scope.stations,(u) ->
            u.checked = false
        @setEquipments scope
      scope.station_select_chan = () =>
        cs = _.map scope.stations,(u) ->
          return !u.checked
        if _.indexOf(cs,true) < 0
          scope.station_all_select = true
        else
          scope.station_all_select = false
        @setEquipments scope
      #########################--type--#########################
      types = _.map scope.project.dictionary.equipmenttypes.items,(s) =>
#        console.log s
        return {name:s.model.name,type:s.model.type,checked:false}
      mvtype = []
      for i in types
        if i.type is "mv"
          mvtype.push(i)
      scope.types = mvtype
      scope.type_all_select = false
      scope.type_all_select_chan = () =>
        if scope.type_all_select
          _.each scope.types,(u) ->
            u.checked = true
        else
          _.each scope.types,(u) ->
            u.checked = false
      scope.type_select_chan = () =>
        cs = _.map scope.types,(u) ->
          return !u.checked
        if _.indexOf(cs,true) < 0
          scope.type_all_select = true
        else
          scope.type_all_select = false
      #########################--equipment--#########################
      _.each scope.project.stations.items,(s) =>
        @getEquipments s,(equips) =>
          @equipments[s.model.station] = equips
      #console.info "@equipments",@equipments
      scope.equipment_all_select = false
      scope.equipment_all_select_chan = () =>
        if scope.equipment_all_select
          _.each scope.equipments,(u) ->
            u.checked = true
        else
          _.each scope.equipments,(u) ->
            u.checked = false
      scope.equipment_select_chan = () =>
        cs = _.map scope.equipments,(u) ->
          return !u.checked
        if _.indexOf(cs,true) < 0
          scope.equipment_all_select = true
        else
          scope.equipment_all_select = false
      #########################--eventSeveritie--#########################
      @geteventSeverities scope,(res) =>
#console.info 'res',res
        scope.eventSeverities = res
        scope.eventSeveritie_all_select = false
        scope.eventSeveritie_all_select_chan = () =>
          if scope.eventSeveritie_all_select
            _.each scope.eventSeverities,(u) ->
              u.checked = true
          else
            _.each scope.eventSeverities,(u) ->
              u.checked = false
        scope.eventSeveritie_select_chan = () =>
          cs = _.map scope.eventSeverities,(u) ->
            return !u.checked
          if _.indexOf(cs,true) < 0
            scope.eventSeveritie_all_select = true
          else
            scope.eventSeveritie_all_select = false

      #########################--user--#########################
      @getRoles scope,(roles) =>
#console.info "roles",roles
        @getUsers scope,roles,(users) =>
          scope.users = users
          @loadRules scope
          scope.user_all_select = false
          scope.user_all_select_chan = () =>
            if scope.user_all_select
              _.each scope.users,(u) ->
                u.checked = true
            else
              _.each scope.users,(u) ->
                u.checked = false
          scope.user_select_chan = () =>
            cs = _.map scope.users,(u) ->
              return !u.checked
            if _.indexOf(cs,true) < 0
              scope.user_all_select = true
            else
              scope.user_all_select = false

      #######################################################################
      scope.save = () =>
#console.info 'save',scope.cate
        if scope.user_all_select
          users = ["_all"]
        else
          filterUsers = _.filter scope.users, (item) =>
            return item.checked
          users = _.map filterUsers, (item) =>
            return item.user
        #console.info 'users',users
        if scope.station_all_select
          rule.allStations = true
        else
          delete rule.allStations
          filterStations = _.filter scope.stations, (item) =>
            return item.checked
          rule.stations = _.map filterStations, (item) =>
            return item.station

        if scope.type_all_select
          rule.allEquipmentTypes = true
        else
          delete rule.allEquipmentTypes
          filterTypes = _.filter scope.types, (item) =>
            return item.checked
          rule.equipmentTypes = _.map filterTypes, (item) =>
            return item.type

        if scope.equipment_all_select
          rule.allEquipments = true
        else
          delete rule.allEquipments
          filterEquipments = _.filter scope.equipments, (item) =>
            return item.checked
          rule.equipments = _.map filterEquipments, (item) =>
            return item.equipment

        if scope.eventSeveritie_all_select
          rule.allEventSeverities = true
        else
          delete rule.allEventSeverities
          filtereventSeverities = _.filter scope.eventSeverities, (item) =>
            return item.checked
          rule.eventSeverities = _.map filtereventSeverities, (item) =>
            return item.severity
        #        console.info 'stations',rule
        save_api =
          id: 'notificationrules'
          item:
            user:scope.project.model.user
            project:scope.project.model.project
            notification:"notification-#{scope.cate}"
            content: "中文测试消息"
            contentType: "template"
            delay: 0
            enable: true
            events: []
            index: 0
            name: "#{scope.cate}-notification"
            phase: "start"
            priority: 0
            processors: []
            repeatPeriod: 0
            repeatTimes: 0
            rule: rule
            ruleType: "complex"
            timeout: 2
            title: "test notification"
            type: scope.cate
            users: users
            visible: true
        @commonService.modelEngine.modelManager.getService(save_api.id).save save_api.item,(e,res) =>
          if res && res._id
            @display "保存告警模板成功",10000

      #改变发件方式
      scope.cates_chan = () =>
        @loadRules scope
#######################################################################
    loadRules: (scope) =>
#      console.info 'users',scope.users
#      console.info 'stations',scope.stations
#      console.info 'types',scope.types
#      console.info 'equipments',@equipments
#      console.info 'eventSeverities',scope.eventSeverities

      scope.user_all_select = false
      scope.station_all_select = false
      scope.type_all_select = false
      scope.equipment_all_select = false

      _.each scope.users,(item) =>
        item.checked = false
      _.each scope.stations,(item) =>
        item.checked = false
      _.each scope.types,(item) =>
        item.checked = false
      _.each scope.equipments,(item) =>
        item.checked = false
      _.each scope.eventSeverities,(item) =>
        item.checked = false

      notificationrules_api =
        id: 'notificationrules'
        query:
          user: scope.project.model.user
          project: scope.project.model.project
          notification: "notification-#{scope.cate}"
      @commonService.modelEngine.modelManager.getService(notificationrules_api.id).get notificationrules_api.query,(e,res) =>
        if res.users && res.rule
          @setRule scope,res
#console.info 'res',res
      ,true
    setRule: (scope,res) =>
      if res.users[0]
        if res.users[0] == "_all"
          scope.user_all_select = true
          _.each scope.users,(item) =>
            item.checked = true
        else
          scope.user_all_select = false
          _.each scope.users,(item) =>
            _.each res.users,(u) =>
              if item.user == u
                item.checked = true
      else
        scope.user_all_select = false

      if res.rule.allStations
        scope.station_all_select = true
        _.each scope.stations,(item) =>
          item.checked = true
      else if res.rule.stations
        scope.station_all_select = false
        _.each scope.stations,(item) =>
          _.each res.rule.stations,(i) =>
            if item.station == i
              item.checked = true

      if res.rule.allEquipmentTypes
        scope.type_all_select = true
        _.each scope.types,(item) =>
          item.checked = true
      else if res.rule.equipmentTypes
        scope.type_all_select = false
        _.each scope.types,(item) =>
          _.each res.rule.equipmentTypes,(i) =>
            if item.type == i
              item.checked = true

      @setEquipments scope
      if res.rule.allEquipments
        scope.equipment_all_select = false
        _.each scope.equipments,(item) =>
          item.checked = true
      else if res.rule.equipments
        scope.equipment_all_select = false
        _.each scope.equipments,(item) =>
          _.each res.rule.equipments,(i) =>
            if item.equipment == i
              item.checked = true

      if res.rule.allEventSeverities
        scope.eventSeveritie_all_select = true
        _.each scope.eventSeverities,(item) =>
          item.checked = true
      else if res.rule.eventSeverities
        scope.eventSeveritie_all_select = false
        _.each scope.eventSeverities,(item) =>
          _.each res.rule.eventSeverities,(i) =>
            if item.severity == i.toString()
              item.checked = true

    getRoles:(scope,callback) ->
      roles_api =
        id: 'roles'
        query:
          user:scope.project.model.user
          project:scope.project.model.project
        field:null
      @commonService.modelEngine.modelManager.getService(roles_api.id).query roles_api.query,roles_api.field,(e,rs) =>
        res = _.map rs,(r) =>
          return r.users
        union = _.union _.flatten res
        callback?union
      ,true
    getUsers:(scope,roles,callback) ->
      if _.indexOf roles,"_all" >= 0
        @commonService.modelEngine.modelManager.getService("users").query null,null,(e,rs) =>
          res = _.map rs,(r) ->
            return {name:r.name,user:r.name,checked:false}
          callback?res
      else
        callback?roles
    getEquipments: (station,callback) ->
      station.loadEquipments null,null,(err, equipments) =>
        equips = _.map equipments,(e) ->
          return {name:e.model.name,equipment:e.model.equipment,checked:false}
        callback?equips
      ,true
    geteventSeverities:(scope,callback) ->
      eventSeverities_api =
        id: 'eventseverities'
        query:
          user:scope.project.model.user
          project:scope.project.model.project
        field:null
      @commonService.modelEngine.modelManager.getService(eventSeverities_api.id).query eventSeverities_api.query,eventSeverities_api.query.field,(e,rs) =>
        res = _.map rs,(r) =>
          return {name:r.name,severity:r.severity.toString(),checked:false}
        callback?res
      ,true
    setEquipments:(scope) ->
      filterStations = _.filter scope.stations,(s) =>
        return s.checked
      mapStations = _.map filterStations,(s) =>
        return @equipments[s.station] || []
      scope.equipments = _.union _.flatten mapStations #所有选中的站点设备
      @$timeout =>
        cs = _.map scope.equipments,(u) ->
          return !u.checked
        if cs.length is 0
          scope.equipment_all_select = false
        else
          if _.indexOf(cs,true) < 0
            scope.equipment_all_select = true
          else
            scope.equipment_all_select = false
      ,0
#console.info scope.equipments
    resize: (scope)->

    dispose: (scope)->

  exports =
    NotificationDirective: NotificationDirective