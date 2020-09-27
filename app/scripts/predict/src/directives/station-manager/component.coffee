###
* File: station-manager-directive
* User: David
* Date: 2018/11/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationManagerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "station-manager"

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      loadStations = () =>
        scope.project?.loadStations null, (err, stations) =>
          scope.allStations = _.filter stations,(data)-> return data.model.station != "_elesys_manager_station"
        ,true
        scope.$applyAsync()
      loadStations()

      scope.prompt = (title, message, callback) ->
        scope.modal =
          title: title
          message: message
          confirm: (ok) ->
            callback? ok, @comment, @password
          preConfirm: ()->
            callback? "preCommand", @comment, @password
        $('#station-manager-prompt-modal').modal('open')
        return

      scope.saveStation = (callback) =>
        if !scope.station.model.name or !scope.station.model.station
          @display '请填写相关数据！'
          return false
        if scope.station.model.name.indexOf(" ")>=0 or scope.station.model.station.indexOf(" ")>=0
          @display '请勿输入空格！'
          return false
        scope.station.save callback
        $('#station-edit-modal').modal('close');
        $('#station-new-modal').modal('close');
        loadStations()

      scope.selectStation = (station)->
        scope.station = station

      scope.removeStation = (station) =>
        title = station.model.name
        msg = ""
        $('#station-manager-prompt-modal').modal('open')
        scope.prompt title, msg, (ok) =>
          return if not ok
          if ok
            station?.remove()
            $('#station-manager-prompt-modal').modal('close')
            loadStations()

      scope.createStation = (parentStation) ->
        $("#station-new-modal").modal('open')
        scope.station = scope.project.createStation parentStation
        console.info scope.controller

      scope.filterStation = () =>
        (station) =>
          if station.model.station.charAt(0) isnt "_" and station.model.station isnt scope.station.model.station
            return true
          return false

      scope.getStationParentName = (stationId) =>
        stationName = _.find @project.stations.items, (station) -> station.model.station is stationId
        if stationName
          return stationName.model.name




    resize: (scope)->

    dispose: (scope)->


  exports =
    StationManagerDirective: StationManagerDirective