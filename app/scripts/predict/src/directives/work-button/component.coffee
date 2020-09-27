###
* File: work-button-directive
* User: David
* Date: 2019/07/17
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "text!./module.html" , "text!./module.css", "text!./tasks.json"], (base, css, view, _, moment, moduleHtml, moduleCss, json) ->
  class WorkButtonDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "work-button"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      today = _.map(moment().format("YYYY-MM-DD").split("-"), (d) ->
        if d.length == 2 and d[0] == "0"
          return d[1]
        return d
      )
      year = parseInt(moment().format("YYYY"))
      scope.queryDay = { day: today[2], month: today[1], year: today[0] }
      scope.options = {
        day: [],
        month: _.map([1..12], (d) -> d),
        year: _.map([0..19], (d) => year - d)
      }

      valideDate = () =>
        isPass = true
        for x in ["day", "month", "year"]
          if scope.queryDay[x] == ""
            isPass = false
            break
        M.toast({ html: '温馨提示：时间不可为空！' }) if !isPass
        return isPass

      scope.changeDays = () =>
        if scope.queryDay.year == "" || scope.queryDay.month == ""
          scope.queryDay.day = ""
          scope.options.day = []
          scope.$applyAsync();
          return;
        count = scope.options.day.length;
        if ["1", "3", "5", "7", "8", "10", "12"].indexOf(scope.queryDay.month) != -1 and count != 31
          scope.options.day = _.map([1..31], (d) -> d)
        else if ["4", "6", "9", "11"].indexOf(scope.queryDay.month) != -1 and count != 30
          scope.options.day = _.map([1..30], (d) -> d)
        else if scope.queryDay.month == "2"
          lastDay = if moment([scope.queryDay.year]).isLeapYear() then 29 else 28
          scope.options.day = _.map([1..lastDay], (d) -> d) if count != lastDay
        scope.$applyAsync();

      warpHtml = (d, h) =>
        html = _.clone(h);
        content = d.nodes[0].contents[0].content
        html = html.replace("{{name}}", d.creator.name)
        html = html.replace("{{time}}", moment(d.createtime).format("YYYY-MM-DD HH:mm:ss"))
        counts = { ups: 2, ac: 3, dme: 2, th: 7, water: 5 }
        datas = ["ups-alarms", "ups-loadRate", "distributor-alarms", "distributor-voltage","battery-alarms",
          "battery-temperature", "battery-humidity", "ac-status", "dme-status", "th-alarms", "th-temperature",
          "th-humidity", "water-alarms", "distributor-temperature", "distributor-humidity"
        ]
        _.map(datas, (item) =>
          items = item.split("-")
          count = if _.has(counts, items[0]) then counts[items[0]] else 1
          for x in [1..count]
            _index = if (items[0] is "distributor" or items[0] is "battery") then items[0] else (items[0] + x)
            _val = content[_index]?[items[1]]
            replaceVal = ""
            if typeof(_val) is "object" and (items[1] is "loadRate" or items[1] is "voltage")
              replaceVal = _.max(_.values(_val))
            else if typeof(_val) is "boolean" and items[1] is "alarms"
              replaceVal = if _val then "告警" else "正常"
            else if typeof(_val) is "string" or typeof(_val) is "number"
              replaceVal = _val
            else
              replaceVal = "--"
            html = html.replace("{{" + _index + "-" + items[1] + "}}", replaceVal)
          if _.has(content, "severities")
            for y in [1, 2, 3]
              _val2 = if content?.severities[y - 1]?.value then content.severities[y - 1].value else "--"
              html = html.replace("{{severities" + y + "-value}}", _val2)
        )
        return html

      printing = (data) =>
        if data.length is 0
          M.toast({ html: '温馨提示：无数据！' })
          return
        _html = ""
        _data = _.sortBy(data, (d) -> d.createtime)
        for x in _data
          _html += warpHtml(x, moduleHtml)
        date = [scope.queryDay.year, scope.queryDay.month, scope.queryDay.day].join("/")
        html = "<html><head><style type=text/css>" + moduleCss + "</style></head><body onbeforeprint='document.getElementsByTagName(`input`)[0].style.display = `none`' onafterprint='document.getElementsByTagName(`input`)[0].style.display = `inline`'><header><h4>江汉油田数据中心机房巡检记录</h4><div>日期：" + date + "<input type='button' onclick='window.print()' value='打印'/></div></header>" + _html + "</body></html>";
        newWindow = window.open()
        newWindow.document.write(html)
        newWindow.document.close()

      scope.setQuery = (type) =>
        $("#tasktime-select").modal('close')
        if type is -1
          return
        if type is 0 and valideDate()
          filter = scope.project.getIds()
          _date = [scope.queryDay.year, scope.queryDay.month, scope.queryDay.day].join("-")
          filter.createtime = {
            "$lte": moment(new Date(_date)).endOf('day')
            "$gte": moment(new Date(_date)).startOf('day')
          }
          @loadGroup(filter,(data) =>
            return console.error("未查询到数据！！") if !data
            printing(data)
          )

      scope.changeDays()

    loadGroup: (param, callback) =>
      @commonService.loadProjectModelByService('tasks', param, '_id user project type process name creator task phase nodes createtime', (err, taskmodels) =>
        callback(taskmodels) if taskmodels
      ,true)

    resize: (scope)->

    dispose: (scope)->


  exports =
    WorkButtonDirective: WorkButtonDirective