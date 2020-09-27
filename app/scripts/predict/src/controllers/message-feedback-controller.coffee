###
* File: message-feedback-controller
* User: Pu
* Date: 2020/03/30
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/controllers/project-base-controller'], (base) ->
  class MessageFeedbackController extends base.ProjectBaseController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) ->
      super $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options


  exports =
    MessageFeedbackController: MessageFeedbackController
