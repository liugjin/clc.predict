###
* File: station-info-controller
* User: Pu
* Date: 2019/12/24
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/controllers/project-base-controller'], (base) ->
  class StationInfoController extends base.ProjectBaseController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) ->
      super $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options

    initialize: ->
      super
      @stationbg = "/predict/res/img/#{@$routeParams.station}.png"    # 切换站点时切换站点的背景图片

  exports =
    StationInfoController: StationInfoController
