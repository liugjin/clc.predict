# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class Graphic3BoxDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "graphic3-box"
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
      scope.templateId =
        user: @$routeParams.user
        project: @$routeParams.project
        template: scope.parameters.templateId
      initializeView=()=>
        scope.placeholder = $('#element-placeholder')
        scope.placeholder.draggable()

        scope.placeholderSize =
          width: scope.placeholder.width()
          height: scope.placeholder.height()
          width2: scope.placeholder.width() / 2
          height2: scope.placeholder.height() / 2

        scope.popover = $('#element-placeholder-popover')
        scope.viewerPosition = $('#player').offset()

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


      scope.movePlaceholderToElement= (element) ->
        return if not element
        # put on element center
        box = element._geometry.node.getBoundingClientRect()
        x = box.left + box.width / 2 - scope.placeholderSize.width / 2
        y = box.top + box.height / 2 - scope.placeholderSize.height / 2
        scope.placeholder.offset
          left: x
          top: y
        return

      scope.applyChange= ()->
# notify angular to update
        scope.$apply() if not scope.$$phase

      scope.initializePlaceholder= ->
        template = scope.template
        updatePlaceholder = () =>
          image = template.getPropertyValue 'placeholder-image'
          x = template.getPropertyValue 'placeholder-x', 50
          y = template.getPropertyValue 'placeholder-y', 50
          width = template.getPropertyValue 'placeholder-width', 20
          height = template.getPropertyValue 'placeholder-height', 20
          scope.placeholderMode = mode = template.getPropertyValue 'placeholder-mode', 'dynamic'
          scope.timelineEnable = template.getPropertyValue 'timeline-enable', false

          # update placeholder
          css =
            left: x
            top: y
            width: width
            height: height
          css['background-image'] = if image then "url(#{scope.controller.setting.urls.uploadUrl}/#{image})" else "url(/visualization/res/img/popover.gif)"
          scope.placeholder.css css

          if mode is 'none'
            scope.placeholder.hide()
          else if mode in ['dynamic', 'element']
            scope.placeholder.draggable 'enable'
            scope.placeholder.show()
          else
            scope.placeholder.draggable 'disable'
            scope.placeholder.show()

          # update placeholder size
          scope.placeholderSize =
            x: x
            y: y
            width: width
            height: height
            width2: width / 2
            height2: height / 2

        template.subscribePropertiesValue ['placeholder-image', 'placeholder-x', 'placeholder-y', 'placeholder-width', 'placeholder-height', 'placeholder-mode'], (d) ->
          updatePlaceholder()
        , 100

        updatePlaceholder()

      scope.onElementChanged= ()->
        (err, d) ->
          console.log err if err

      scope.onTemplateLoad= ()=>
        (err, template) =>
          console.log err if err
          return if not template
          scope.element = scope.template = template
          console.log "#{new Date().toISOString()} load template #{template.id}"
          scope.templateParameters = null
          # set template parameters based on route parameters
          #        template.setParameters @$routeParams
          scope.initializePlaceholder()

          # element selection event
          template.subscribe (d) =>
            element = d.element
            mode = template.getPropertyValue 'placeholder-mode'
            # move placeholder only the element has tooltip defined
            if mode is 'element' and element?.getPropertyValue('tooltip')
              console.log "订阅得到元素的tooltop"
              scope.movePlaceholderToElement element

            scope.element = element ? template
            # rx thread is different from angular
            scope.applyChange()
          , 'select', 100

      html = '''
      <div class='box-hexagon'>
        <!-- <div class='big-box-border-top' style="background-image:url({{getComponentPath('images/bigcc.png')}})"></div> -->
        <div class='box-content' style="height:{{parameters.height}}">
          <div id="player" ng-dblclick="controller.showPopover($event)">
              <div graphic-player="graphic-player" options="graphicOptions" template-id="templateId"
                   controller="controller" on-template-load="onTemplateLoad()"
                   on-element-changed="onElementChanged()" parameters="parameters"
                   class="graphic-viewer"></div>
              <div id="element-placeholder" ng-show='scope.placeholderMode != "none"'
                 data-activates="placeholder-menu" md-dropdown="md-dropdown" data-hover="false" data-beloworigin="true"
                 title2="信息窗口">
                <div id="element-placeholder-popover" style="width:100%; height:100%;" ng-click2="togglePopover($event)"
                     element-popover="element-popover" data-style="inverse"
                     data-title="{{element.propertyValues.name || controller.element.id}}"
                     element="element" controller="controller" data-trigger="manual" data-placement="auto"
                     data-closeable="true" data-dismissible="false" data-animation="fade"
                     title2="信息展示：在选中项前双击即可弹出信息窗口"></div>
            </div>
          </div>
        </div>
        <!-- <div class='big-box-border-bottom' style="background-image:url({{getComponentPath('images/bigcc.png')}})"></div> -->
      </div>
      '''
      ele = @$compile(html)(scope)
      element.find("#graphic").empty()
      element.find("#graphic").append(ele)
      #      console.log "-----加载scope-----"
      #      console.log scope


      scope.$watch "parameters.templateId",(templateId)=>
        return if not templateId
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: scope.parameters.templateId
        initializeGraphicOptions()
        initializeView()

      #      scope.menuSubscription?.dispose()
      #      scope.menuSubscription = @commonService.subscribeEventBus 'menu-collapsed',(d)=>
      ##        console.log "-----组态内容自动适应容器---"
      ##        window.dispatchEvent(new Event('resize'))
      #        setTimeout ()=>
      #          if scope.controller.player.renderer.transformControl
      #            scope.controller.player.renderer?.transformControl?.stretch()
      #        ,500

      #   菜单缩放 图表自适应
      scope.resize=()=>
        @$timeout =>
          if scope.controller.player.renderer.transformControl
            scope.controller.player.renderer?.transformControl?.stretch()
        ,100
      window.addEventListener 'resize', scope.resize


    resize: (scope)->

    dispose: (scope)->
      scope.menuSubscription?.dispose()


  exports =
    Graphic3BoxDirective: Graphic3BoxDirective