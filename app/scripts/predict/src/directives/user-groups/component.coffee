###
* File: user-groups-directive
* User: David
* Date: 2019/07/04
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class UserGroupsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "user-groups"
      super $timeout, $window, $compile, $routeParams, commonService
      @allUsers = []
      @allGroups = []
      @groupService = commonService.modelEngine.modelManager.getService("groups")
      @userService = commonService.modelEngine.modelManager.getService("users")
    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 全局信息 - 渲染数据
      scope.forminfo = [
        [{title:"部门ID", edit: true, field: "groupId" },{title:"部门名称", field: "groupName", edit: true}],
        [{title:"负责人", field: "manager", type: "select", option: [], edit: true},{title:"部门上级", type: "select", option: [], field: "superior", edit: true}]
      ]
      scope.memberList = []
      scope.groupInfo = { groupId: "", groupName: "", manager: "", superior: "" }
      scope.groupList = []
      scope.userList = []
      scope.selectNodeId = null
      scope.showAddSelect = false
      scope.addUser = ""

      updateGroup = () =>
        scope.addUser = ""
        scope.showAddSelect = false
        if scope.forminfo[0][0].edit and _.find(scope.groupList, (d) => d.value is scope.groupInfo.groupId)
          M.toast({ html: '部门ID已被占用！！' })
          return
        else if scope.forminfo[0][0].edit and !_.find(scope.groupList, (d) => d.groupId is scope.groupInfo.groupId)
          _user = _.find(@allUsers, (d) => d.user is scope.groupInfo.manager)
          obj = {
            name: scope.groupInfo.groupName
            manager: {id:scope.groupInfo.manager,name:_user?.name}
            group: scope.groupInfo.groupId
            parent: scope.groupInfo.superior
            engineers: _.map(scope.memberList, (d) -> { id: d.value, name: d.name, title: "employee" })
          }
          @groupService.save(_.extend(obj,scope.project.getIds()), (err, group) =>
            if err
              @display "错误提示：" + err
              return
            @allGroups.unshift(group)
            warpGroups(@allGroups)
          )
        else if !scope.forminfo[0][0].edit and scope.groupInfo.superior != scope.groupInfo.groupId
          _group = _.find(@allGroups, (d) => d.group is scope.groupInfo.groupId)
          _user = _.find(@allUsers, (d) => d.user is scope.groupInfo.manager)
          obj = {
            _id: _group._id
            name: scope.groupInfo.groupName
            manager: {id:scope.groupInfo.manager,name:_user?.name}
            group: scope.groupInfo.groupId
            parent: scope.groupInfo.superior
            engineers: _.map(scope.memberList, (d) -> { id: d.id, name: d.name, title: "employee" })
          }
          @groupService.update(_.extend(obj,scope.project.getIds()), (err, group) =>
            return console.warn("更新失败！！") if !group
            warpGroups(@allGroups)
          )
        else if !scope.forminfo[0][0].edit and scope.groupInfo.superior == scope.groupInfo.groupId
          M.toast({ html: '不能将部门自身作为部门上级！！' })
          return

      delGroup = () =>

        childGroups = _.find(@allGroups, (d) => d.parent is scope.groupInfo.groupId)
        if childGroups
          @display "温馨提示：该部门存在子部门，先删除子部门再删除此部门，请查证！"
          return
        _group = _.find(@allGroups, (d) => d.group is scope.groupInfo.groupId)
        @groupService.remove(_group, (err, group) =>
          return console.warn("删除失败！！") if !group
          tmpGroups = _.filter @allGroups,(item)->
            return item.group != group[0].group
          @allGroups = tmpGroups
          warpGroups(_.filter(@allGroups, (d) => d.group != _group.group))
        )

      # button - 点击事件
      # 部门 的 "新增" / "保存" / "删除"
      scope.btnClick = (type) =>
        if type is 0
          #保存部门信息
          if scope.groupInfo.groupId is "" || scope.groupInfo.groupName is ""
            M.toast({ html: '部门ID/部门名称不可为空！！' })
            return
          updateGroup()
        else if type is 1
          #新增模式！！ 置空表单数据
          scope.memberList = []
          scope.groupInfo = { groupId: (@getUniqueName scope.groupList, "depart", 'value', 1), groupName: (@getUniqueName scope.groupList, "部门", 'name', 1), manager: "", superior: "" }

          scope.forminfo[0][0].edit = true
        else if type is -1
          #删除模式
          if scope.groupInfo.groupId is ""
            warpGroups(@allGroups)
            return

          scope.prompt '温馨提示','是否确定删除' + scope.groupInfo.groupName + "?",(ok, comment)=>
            return if not ok
            delGroup()

      # 部门选中事件
      scope.selectGroup = (index, item) =>
        if index != scope.selectNodeId
          scope.forminfo[0][0].edit = false
          scope.selectNodeId = index
          scope.groupInfo = {
            groupId: item.value,
            groupName: item.name,
            manager: if item.manager then item.manager.id else "",
            superior: if item.parent then item.parent else ""
          }
          scope.memberList = if item.member then item.member else []
          scope.$applyAsync();

      # 部门成员组 的 "新增" / "删除"
      scope.updateMember = (index) =>
        if typeof(index) is "number"
          scope.memberList = _.filter(scope.memberList, (d) => d.id isnt scope.memberList[index].id)
          scope.showAddSelect = false
          scope.$applyAsync();
        else
          hasUser = _.find(scope.memberList, (d) => d.id is index)
          addUserObj = _.find(scope.userList, (d) => d.value is index)
          if !hasUser and addUserObj
            scope.memberList.push({ name: addUserObj.name, title: "employee", id: addUserObj.value})
            scope.addUser = ""
            scope.$applyAsync();
          else
            M.toast({
              html: if index == "" then "不可选择空用户！！" else '请选择一个不在部门内的用户！！'
            })

      # 处理
      warpGroups = (groups) =>
        groupOption = _.map(groups, (d) =>
          parent = null
          parent = _.find(groups, (m) => m.group is d.parent) if _.has(d, "parent")
          return { name:d.name, value:d.group, manager:d?.manager , parent: d?.parent, parentName: parent?.name, member: d.engineers }
        )
        if groupOption.length > 0 and _.isNull(scope.selectNodeId)
          scope.selectNodeId = 0
          scope.forminfo[0][0].edit = false
          scope.groupInfo = {
            groupId: groupOption[0].value,
            groupName: groupOption[0].name,
            manager: if groupOption[0].manager then groupOption[0].manager.id else "",
            superior: if groupOption[0].parent then groupOption[0].parent else ""
          }
          scope.memberList = groupOption[0].member
        else if groupOption.length > 0 and typeof(scope.selectNodeId) is "number"
          scope.forminfo[0][0].edit = false
          scope.groupInfo = {
            groupId: groupOption[scope.selectNodeId].value,
            groupName: groupOption[scope.selectNodeId].name,
            manager: if groupOption[scope.selectNodeId].manager then groupOption[scope.selectNodeId].manager.id else "",
            superior: if groupOption[scope.selectNodeId].parent then groupOption[scope.selectNodeId].parent else ""
          }
          scope.memberList = groupOption[scope.selectNodeId].member
        scope.forminfo[1][1].option = groupOption
        scope.groupList = groupOption
        scope.$applyAsync();

      # 初始化 获得用户和用户组
      init = () =>
        @loadUser((users) =>
          userOption = _.map(users, (d) -> { name:d.name, value:d.user })
          scope.forminfo[1][0].option = userOption
          scope.userList = userOption
          scope.$applyAsync();
        );
        @loadGroup((groups) =>
          warpGroups(groups)
        );
      init();

    loadUser: (callback) =>
      @userService.query({}, 'user name', (err, userModels) =>
        if userModels
          @allUsers = userModels
          callback(userModels)
      )
    loadGroup: (callback) =>
      filter = {}
      filter.user = @$routeParams.user
      filter.project = @$routeParams.project
      @groupService.query filter, 'group name manager parent engineers', (err, groupModels) =>
        if groupModels
          @allGroups = groupModels
          callback(groupModels)
      ,true

    getUniqueName: (items, prefix, property, index = 1) ->
      name = "#{prefix}-#{index}"
      if items
        for item in items
          if item[property] is name
            return @getUniqueName items, prefix, property, index + 1
      name
    resize: (scope)->

    dispose: (scope)->


  exports =
    UserGroupsDirective: UserGroupsDirective