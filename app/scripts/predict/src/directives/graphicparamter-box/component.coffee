###
* File: graphicparamter-box-directive
* User: James
* Date: 2019/03/29
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class GraphicparamterBoxDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "graphicparamter-box"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      templateId:"@"

    setCSS: ->
      css

    applyChange:->
      return ()=>
        scope.$applyAsync()

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
#      window.debugR = scope
#      scope.controller = @
      scope.graphic_parameters = {}
      if scope.parameters.templateParameters
        scope.graphic_parameters = scope.parameters.templateParameters

      if scope.parameters.templateId
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: scope.parameters.templateId
      else
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: @$routeParams.station

      scope.$watch "parameters",(templateId)=>
        return if not templateId
        #        element.find(".box-hexagon").remove()
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: scope.parameters.templateId
          parameters: scope.parameters.templateParameters


      initializeView=()=>
        if _.isNull(document.getElementById('#element-placeholder'))
          setTimeout(initializeView, 1000)
          return
        @placeholder = $('#element-placeholder')
        @placeholder.draggable()

        @placeholderSize =
          width: @placeholder.width()
          height: @placeholder.height()
          width2: @placeholder.width()/2
          height2: @placeholder.height()/2

        @popover = $('#element-placeholder-popover')

        @viewerPosition = $('#player').offset()

      initializeGraphicOptions=() =>
        scope.graphicOptions =
          engineOptions:
            parameters: @$routeParams
          renderOptions:
            editable: false
            type: @$routeParams.renderer ? @$rootScope?.renderType ? 'snapsvg'
            uploadUrl: window?.setting?.urls?.uploadUrl

      initializeGraphicOptions()
      initializeView()
      html = '''
      <div class='box-hexagon'>
        <div class='{{parameters.noBorderStyle?"":"big-box-border-top"}}'></div>
        <div class='{{parameters.noBorderStyle?"":"box-content"}} max-height'>
          <div id="player" ng-dblclick="controller.showPopover($event)">
              <div graphic-player="graphic-player" options="graphicOptions" template-id = "templateId"
                   controller="controller" on-template-load="controller.onTemplateLoad()"
                   on-element-changed="controller.onElementChanged()" parameters="graphic_parameters"
                   class="graphic-viewer"></div>
          </div>
        </div>
        <div class='{{parameters.noBorderStyle?"":"big-box-border-bottom"}}'></div>
      </div>
      '''
      ele = @$compile(html)(scope)
      element.find("#graphicparamter").empty()
      element.find("#graphicparamter").append(ele)
      scope.element = element
#        initializeGraphicOptions()
#        initializeView()
#        ele = @$compile(html)(scope)
#        element.find("#graphicparamter").empty()
#        element.find("#graphicparamter").append(ele)

    resize: (scope)->

    dispose: (scope)->
      scope.element?.find("#graphicparamter").empty()
      scope.templateId = null
      @placeholder = null



  exports =
    GraphicparamterBoxDirective: GraphicparamterBoxDirective