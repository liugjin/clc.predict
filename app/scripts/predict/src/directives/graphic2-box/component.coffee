###
* File: graphic-box-directive
* User: David
* Date: 2018/11/16
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "jquery.ui"], (base, css, view, _, moment) ->
  class Graphic2BoxDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "graphic-box"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      templateId:"="
      noBorderStyle: "="

    setCSS: ->
      css

    applyChange:->
      return ()=>
        scope.$applyAsync()

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      #      scope.controller = @
      tempSrc = ''
      level=''
      reg=/replace">[\s\S]+</g
      @commonService.loadEquipmentById scope.station,@$routeParams.equipment,(err,equip)=>
        equip?.loadProperties null, (err, properties) =>
          scope.equipment = equip
          scope.knowledge_base = JSON.parse(scope.equipment.propertyValues?._knowledge_base || '{}')

      faultObj = {
        "abrasion":"svg-image-6",
        "deposit":"svg-image-2",
        "fall":"svg-image-5",
        "fixture":"svg-image-1",
        "short":"svg-image-3",
        "arrester-fault":"svg-image-18",
        "breaker-fault":"svg-image-2",
        "busbar-fault":"svg-image-3",
        "cable-fault":"svg-image-5",
        "current-transformer-fault":"svg-image-6",
        "earthing-switch-fault":"svg-image-7",
        "static-contact-fault":"svg-image-8",
        "ash":"svg-image-20",
        "capacitance-aging":"svg-image-19",
        "control-board-ash":"svg-image-23",
        "fan-aging":"svg-image-22",
        "oxidation":"svg-image-1",
        "switch-tube":"svg-image-2",
        "coil-fault":"svg-image-18",
        "cool-oil-fault":"svg-image-2",
        "high-tension-fault":"svg-image-3",
        "iron-core-fault":"svg-image-4",
        "structure-fault":"svg-image-6"
      }
      if scope.parameters.templateId
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: scope.parameters.templateId
      #@commonService.loadEquipmentById
#      console.log '2', @$routeParams

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

      #      initializeGraphicOptions()
      #      initializeView()

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

      scope.initializePlaceholder= =>
        template = scope.template
#        console.log 'scope.template', scope.template

        # 触发部件弹窗方式1 根据页面左侧设备主要预测参数点击触发部件弹窗
        scope.selectSubscribe?.dispose()
        scope.selectSubscribe = @commonService.subscribeEventBus 'select',(d)=>
#          console.log '-----1--点击预测参数触发弹窗-----',d
          console.log(d)
          element = scope.template.elements[faultObj[d.message.data.signalID]||'']
          ###if d.message.data.signalID is 'abrasion'
            element = scope.template.elements["svg-image-6"]
          else if d.message.data.signalID is 'deposit'
            element = scope.template.elements["svg-image-2"]###
          mode = template.getPropertyValue 'placeholder-mode'
          # move placeholder only the element has tooltip defined
          if mode is 'element' and element?.getPropertyValue('tooltip')
#            console.log 'element1',element
            level='level'+Math.floor(parseInt(element.propertyValues['channel1']||0)/25 + 1)
            if level == 'level5'
                level = 'level4'
#            console.log 'level',level
#            console.log  scope.knowledge_base[d.message.data.signalID][level]
#            console.log 'element1tooltip',typeof element?.getPropertyValue('tooltip')
            element?.setPropertyValue('tooltip',element?.getPropertyValue('tooltip').replace(reg,'replace">'+scope.knowledge_base[d.message.data.signalID][level]+'<'))
            scope.movePlaceholderToElement element
          scope.element = element ? template


        # 触发部件弹窗方式2 订阅信号根据订阅的信号找到此信号的图元 触发点击事件进而触发弹窗
        scope.predictSubscribe = {}
        topic = "#{scope.controller.$routeParams.user}/#{scope.controller.$routeParams.project}/#{scope.controller.$routeParams.station}/#{scope.controller.$routeParams.equipment}"
        filter = {
          user: scope.controller.$routeParams.user
          project: scope.controller.$routeParams.project
          station: scope.controller.$routeParams.station
          equipment: scope.controller.$routeParams.equipment
        }
        scope.predictSubscribe[topic]?.dispose()
        scope.predictSubscribe[topic]=@commonService.signalLiveSession.subscribeValues filter, (err,d)=>
          if (d.message.signal in Object.keys(faultObj)) and (d.message.severity > 0) and (d.message.mode is 'event')
#            console.log '---2--订阅到了触发部件弹窗的信号--'
#            console.log d
            setTimeout ()=>
              element = scope.template.elements[faultObj[d.message.signal]]
              mode = template.getPropertyValue 'placeholder-mode'
              # move placeholder only the element has tooltip defined
              if mode is 'element' and element?.getPropertyValue('tooltip')
                level='level'+Math.floor(parseInt(element.propertyValues['channel1']||0)/25 + 1)
                if level == 'level5'
                  level = 'level4'
#                console.log 'level',level
#                console.log  scope.knowledge_base[d.message.signal][level]
#                console.log 'element1tooltip',typeof element?.getPropertyValue('tooltip')
                element?.setPropertyValue('tooltip',element?.getPropertyValue('tooltip').replace(reg,'replace">'+scope.knowledge_base[d.message.signal][level]+'<'))
                scope.movePlaceholderToElement element
              scope.element = element ? template
              scope.applyChange()
#              scope.placeholder.webuiPopover 'show'
            ,2000

        updatePlaceholder = () =>
          image = template.getPropertyValue 'placeholder-image'
          x = template.getPropertyValue 'placeholder-x', 50
          y = template.getPropertyValue 'placeholder-y', 50
          width = template.getPropertyValue 'placeholder-width', 20
          height = template.getPropertyValue 'placeholder-height', 20
          scope.placeholderMode = mode = template.getPropertyValue 'placeholder-mode', 'dynamic'
          scope.timelineEnable = template.getPropertyValue 'timeline-enable', false
#          console.log 'scope.placeholder',scope.placeholder

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
          conosle.log "hello",d
          updatePlaceholder()
        , 100

        updatePlaceholder()

      scope.onElementChanged= ()->
        (err, d) ->
          console.log err if err

      scope.onTemplateLoad= ()=>

        (err, template) =>
#          console.log template
          console.log err if err
          return if not template
          #new Promise((resolve, reject)=>
         #   resolve(1)
         # ).then((data)=>
          #   console.log data
          #).catch((err)=>
          #  console.log 2
        #  )
          #2D模型高亮处置：在视图的模板参数配置相同参数不同颜色的svg，onmouseover替换
          for item of template.elements
            template.elements[item]._geometry.node.querySelector("image")?.setAttribute('id',item)
            #tempTooltip=template.elements[item].getPropertyValue("tooltip")
           # $("#"+item).webuiPopover({content:tempTooltip,closeable:true,trigger:'sticky'})
            #$("#"+item).webuiPopover('show')
            #console.log item
            template.elements[item]._geometry.node.querySelector("image")?.onmouseover=(i)=>
              for imgItem,key in template.model.parameters
                if imgItem.id == i.target.id
                   tempSrc = template.elements[i.target.id].template.elements[item]
                   template.elements[i.target.id].setPropertyValue("src",template.model.parameters[key].value)
                   template.elements[i.target.id]._geometry.node.querySelector("image")?.onmouseout=(e)=>
                      template.elements[e.target.id].setPropertyValue("src",tempSrc)

          scope.element = scope.template = template
          console.log "#{new Date().toISOString()} load template #{template.id}"
          scope.templateParameters = null
          # set template parameters based on route parameters
          #        template.setParameters @$routeParams
          scope.initializePlaceholder()

          # element selection event
          template.subscribe (d) =>
#            console.log 'graphic player',scope.template.player
            element = d.element
            #d.last?.setPropertyValue('border-color','transparent')
           # d.last?.setPropertyValue('border-width','0')
            #if d.element?.propertyValues.geometry != 'template' && d.element?.propertyValues.name != '名称线'
             # element?.setPropertyValue('border-color','blue')
             # element?.setPropertyValue('border-width','2px')
#            console.log element
            mode = template.getPropertyValue 'placeholder-mode'
            # move placeholder only the element has tooltip defined
            if mode is 'element' and element?.getPropertyValue('tooltip')
              level='level'+Math.floor(parseInt(element.propertyValues['channel1']||0)/25 + 1)
              if level == 'level5'
                level = 'level4'
#              console.log 'level',level
#              console.log element.propertyValues['channel4']
              element?.setPropertyValue('tooltip',element?.getPropertyValue('tooltip').replace(reg,'replace">'+scope.knowledge_base[element.propertyValues['channel4']][level]+'<'))
              scope.movePlaceholderToElement element

            scope.element = element ? template
            # rx thread is different from angular
            scope.applyChange()
          , 'select', 100

      html = '''
      <div class='box-hexagon'>
        <div class='{{parameters.noBorderStyle?"":"big-box-border-top"}}'></div>
        <div class='{{parameters.noBorderStyle?"":"box-content"}} max-height'>
          <div id="player" ng-dblclick="controller.showPopover($event)" >
              <div graphic-player="graphic-player" options="graphicOptions" template-id="templateId"
                   controller="controller" on-template-load="onTemplateLoad()"
                   on-element-changed="onElementChanged()" parameters="parameters"
                   class="graphic-viewer"></div>
              <div id="element-placeholder" ng-show='placeholderMode != "none"'
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
        <div class='{{parameters.noBorderStyle?"":"big-box-border-bottom"}}'></div>
      </div>
      '''

      initializeGraphicOptions()
      initializeView()
      ele = @$compile(html)(scope)
      element.find("#graphic").empty()
      element.find("#graphic").append(ele)
      scope.$watch "parameters.templateId",(templateId)=>
        return if not templateId
        #        element.find(".box-hexagon").remove()
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: scope.parameters.templateId
          parameters: scope.parameters.templateParameters
        initializeGraphicOptions()
        initializeView()

#        initializeGraphicOptions()
#        initializeView()
#        ele = @$compile(html)(scope)
#        element.find("#graphic").empty()
#        element.find("#graphic").append(ele)

    resize: (scope)->

    dispose: (scope)->
      scope.selectSubscribe?.dispose()
      _.map scope.predictSubscribe,(item)->
        item.dispose()

  exports =
    Graphic2BoxDirective: Graphic2BoxDirective
