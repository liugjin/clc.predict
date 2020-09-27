###
* File: alarm-setting-directive
* User: David
* Date: 2019/07/04
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class AlarmSettingDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "alarm-setting"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.templates = []
      scope.list = []
      scope.events = {}
      scope.sort = {}
      templates = {}
      scope.severities = _.sortBy scope.project.dictionary.eventseverities.items,(item)->item.model.severity

      scope.getSeverityName = (severity) ->
        item = _.find scope.severities, (item)->item.model.severity is severity
        item?.model.name

      scope.getCountBySeverity = (severity) ->
        items = _.filter scope.list, (item)->item.severity is severity
        items?.length

      scope.selectSeverity = (severity) ->
        scope.severity = severity

      scope.sortBy = (id) ->
        scope.sort.predicate = id
        scope.sort.reverse = !scope.sort.reverse

      scope.filterEvent = ()=>
        (event) =>
          if scope.severity and event.severity isnt scope.severity
            return false
          text = scope.search?.toLowerCase()
          if not text
            return true
          if event.name.toLowerCase().indexOf(text) >= 0
            return true
          if event.content?.toLowerCase().indexOf(text) >= 0
            return true
          if event.value?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      scope.selectTemplateId = (templateId) =>
        scope.selectTemplate(templates[templateId])

      scope.selectTemplate = (template) =>
        return if not template
        scope.severity = null
        scope.list = []
        scope.events = {}
        scope.currentTemplate = template
        if template is "all"
          @loadTemplateIndexEvents scope, 0
        else
          @loadTemplateEvents scope, template

      scope.saveSetting = =>
        for event in scope.list
          if event.value isnt event.newvalue or event.severity isnt parseInt(event.newseverity) or event.changeAbleFlag is true
            if event.newvalue !=""
              @saveEvent scope, event
            else
              M.toast({ html: '告警阈值格式错误，请重新输入' })
              return false


      scope.controller.$rootScope.executing = true
      scope.project.loadEquipmentTemplates null, null, (err, tmps) =>
        tmps = _.filter tmps, (tmp) -> tmp.model.template.substr(0,1) isnt "_"
        n = 0
        _.each tmps, (tmp) =>
          tmp.loadEvents null, (err, evts) =>
            n++
            templates[tmp.model.type+"."+tmp.model.template] = tmp if evts.length > 0
            if n is tmps.length
              stations = @commonService.loadStationChildren scope.station, true
              j = 0
              for station in stations
                station.loadEquipments null, null, (err, equips) =>
                  j++
                  group = _.groupBy equips, (equip)->equip.model.type+"."+equip.model.template
                  keys = _.keys group
                  for key in keys
                    scope.templates.push templates[key] if templates[key] and _.indexOf(scope.templates, templates[key]) is -1
                    scope.selectTemplate templates[key] if @$routeParams.template is key
                  if j is stations.length and not @$routeParams.template
                    setTimeout =>
                      scope.selectTemplate "all"
                    ,10

      scope.switchEventAble = (lis)->
        if lis.changeAbleFlag
          lis.changeAbleFlag = !lis.changeAbleFlag
        else
          lis.changeAbleFlag = true

      scope.editEventSeverity = (event, index) ->
        event.show = true
        setTimeout ->
          $('#event'+index).parent().find("input").click()
        ,20

    loadTemplateIndexEvents: (scope, index)->
      return if scope.currentTemplate isnt "all"
      template = scope.templates[index]
      if template
        @loadTemplateEvents scope, template, =>
          setTimeout =>
            @loadTemplateIndexEvents scope, index+1
          ,100

    loadTemplateEvents: (scope, template, callback) ->
      template.loadEvents null, (err, events) =>
        for event in events
          scope.events[event.key] = event
          for rule in event.model.rules
            evt =
              key: event.key
              enable: event.model.enable
              type: event.model.type
              templateId: event.model.template
              template: template.model.name
              event: event.model.event,
              name: event.model.name,
              rule: rule.name
              content: rule.title,
              value: rule.start.condition.values,
              newvalue: rule.start.condition.values,
              severity: rule.severity
              newseverity: rule.severity?.toString()
            scope.list.push evt
        scope.$applyAsync()
        scope.controller.$rootScope.executing = false
        callback?()

    saveEvent: (scope, item) ->

      console.log item

      event = scope.events[item.key]
      console.log event
      event.model.enable = item.enable   #修改event的enable状态
      rule = _.find event.model.rules, (it)->it.name is item.rule   # 修改event的告警规则参数
      console.log rule
      rule.severity = parseInt item.newseverity if rule
      rule.start.condition.values = item.newvalue if rule
      event.save (err, result)->
        if not err
          item.severity = parseInt item.newseverity
          item.value = item.newvalue
          item.changeAbleFlag = false #保存成功后 要把所有的changeAbleFlag 设置为false


    resize: (scope)->

    dispose: (scope)->


  exports =
    AlarmSettingDirective: AlarmSettingDirective