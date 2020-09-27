###
* File: task-timeline-directive
* User: David
* Date: 2019/06/28
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
	class TaskTimelineDirective extends base.BaseDirective
		constructor: ($timeout, $window, $compile, $routeParams, commonService)->
			@id = "task-timeline"
			super $timeout, $window, $compile, $routeParams, commonService

		setScope: ->

		setCSS: ->
			css

		setTemplate: ->
			view

		show: (scope, element, attrs) =>
			stateList = { reject: "拒绝", cancel: "取消", approval: "接受" }
			# 全局参数渲染页面
			scope.taskId = null
			scope.data = []
			scope.selectNodeId = null
			# 点击事件 -- 查看节点的内容content
			scope.openDetail = (item, index) =>
				if scope.selectNodeId is index
					scope.selectNodeId = null
					scope.currentContent = {}
					return
				scope.selectNodeId = index
				scope.currentContent = scope.data[index].contents

			scope.currentContent = {}

			# 将task节点的内容content，转化
			warpDetail = (data) =>
				if !data or data?.length <= 1
					return []
				arr = []
				_.map(data[1].content, (d) =>
					if d?.equiptype is "ups" or d?.equiptype is "environmental"
						_.map(d.equips, (equip, index1) => _.map(equip.value, (m, index2) =>
							if index2 is 0
								arr.push({ type: d?.equiptype, typeName: d.equiptypeName, equipment: equip.equipment, equipmentName: equip.equipmentName, value: m.name + "：" +m.value, row: equip.value.length })
							else
								arr.push({ type: d?.equiptype, typeName: d.equiptypeName, value: m.name + "：" +m.value })
						))
					else if d?.equiptype is "meter"
						_.map(d.equips, (equip) =>
							arr.push({ type: "meter", typeName: d.equiptypeName, equipment: equip.equipment,value: equip.equipmentName + "：" +equip.value })
						)
					else if d?.equiptype is "systemstatus"
						_.map(d.equips, (equip) =>
							arr.push({ type: "systemstatus", typeName: d?.equiptypeName, equipment: equip.equipment, equipmentName: equip.equipmentName, value: equip.checked })
						)
					else if typeof(d) is "string"
						arr.push({ type: "memo", typeName: "备注", value: d })
				)
				return _.groupBy(arr, (d) -> d.type)
			
			# 监听传入的task
			scope.$watch("parameters.datas", (datas) =>
				return if !datas?.nodes
				scope.data = _.map(datas.nodes, (node) =>
					return {
						nodeName: node.name,
						state: stateList[node.state],
						manager: node?.manager?.name,
						timestamp: if _.has(node, "timestamp") then moment(node.timestamp).format("YYYY-MM-DD HH：MM：SS") else ""
						contents: warpDetail(node?.contents)
					}
				)
				scope.taskId = if datas?.phase?.progress isnt 1 then datas.task + "  ( 进行中 )" else datas.task + "  ( 已完成 )"
				scope.$applyAsync()
			)

		resize: (scope)->

		dispose: (scope)->


	exports =
		TaskTimelineDirective: TaskTimelineDirective
