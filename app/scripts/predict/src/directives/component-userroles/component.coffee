###
* File: component-userroles-directive
* User: James
* Date: 2018/11/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ComponentUserrolesDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "component-userroles"
      super $timeout, $window, $compile, $routeParams, commonService
      @$routeParams = $routeParams
      @roleService = commonService.modelEngine.modelManager.getService("roles")
      @userService = commonService.modelEngine.modelManager.getService("users")
      @logonUser = commonService.$rootScope.user

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @scope = scope
      @init()

      @scope.saveUser = ()=>


      @scope.roleDetails = ()=>


    init:()=>
      @scope.hasRoles = {}
      @scope.allUserFlag = false
      @scope.allUserCheckFlags = {}
      @scope.roleObj = {}
      @scope.roles = []

      @queryRoles()

      filter2 = {}
      if @logonUser.user.toLowerCase() != "admin"
        filter2.user = @$routeParams.user
      @userService.query filter2, null, (err, model) =>
        if model
          if model[0].group
            filter3 = {}
            filter3.group = model[0].group
            @userService.query filter2, null, (err, model3) =>
              @scope.users = model
          else
            @scope.users = model

      @scope.userRoleDetails = (refData,key)=>
        $('.roles-active').removeClass('active')
        $('#roles'+key).addClass('active')
        @scope.roleObj = refData
        @resetCheckFlags()
        @scope.allUserFlag = false
        if refData.users
          if refData.users[0] == "_all"
            @scope.allUserFlag = true
          else
            @scope.allUserFlag = false
            for userItem in refData.users
                @scope.allUserCheckFlags[userItem] = true


      @scope.saveRoles = ()=>
        if _.isEmpty @scope.roleObj
          @display null, '温馨提示：请选择角色！'
          return

        rejectRoles = _.reject @scope.roles,(data)=>
          return data.role == @scope.roleObj.role

        #获取除该被选角色之外的其他角色包含的用户
        otherRoleUsers = {}
        for rejectRoleItem in rejectRoles
          if rejectRoleItem.users[0] != "_all"
            for rejectUserItem in rejectRoleItem.users
                otherRoleUsers[rejectUserItem] = rejectUserItem


        tmpUsers = []
        strUsers = ""
        tipFlag = false
        tipFlag =  _.mapObject @scope.allUserCheckFlags,(val,key)=>
          if val
            tmpUsers.push key
            if otherRoleUsers[key]
              strUsers += key + "、"

        if strUsers.length > 0
          @display null, '温馨提示：' + strUsers + '用户已分配角色，不能再分配，请查证！'
          return


        @scope.roleObj.users = tmpUsers
        @roleService.save @scope.roleObj,(err,data)=>
          @queryRoles()
          @display err, '操作成功！'

    queryRoles:()->
      #根据用户和项目获取角色数据
      filter = @scope.project.getIds()
      @roleService.query filter, null, (err, model) =>
        @scope.roles = model
        for modelItem in model
          if modelItem.users.length > 0
            for userItem in modelItem.users
              @scope.hasRoles[userItem] = userItem
      ,true

    resetCheckFlags:()->
      if @scope.users
        if @scope.users.length > 0
          for userItem in @scope.users
            @scope.allUserCheckFlags[userItem.user] = false
    resize: (scope)->

    dispose: (scope)->


  exports =
    ComponentUserrolesDirective: ComponentUserrolesDirective