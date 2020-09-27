###
* File: routes
* User: Dow
* Date: 2014/10/24
###

# compatible for node.js and requirejs
`if (typeof define !== "function") { var define = require("amdefine")(module) }`

define ["clc.foundation.angular/router"], (base) ->
  class Router extends base.Router
    constructor: ($routeProvider) ->
      super $routeProvider

    start: () ->
      namespace = window.setting.namespace ? "predict"

      @routeTemplateUrl "/home", "/#{namespace}/home/templates/index", "HomeController"
      @routeTemplateUrl "/config", "/#{namespace}/home/templates/config", "HomeController"

      namespace += "/portal"

      @routeTemplateUrl "/login", "/#{namespace}/templates/login", "LoginController"
      @routeTemplateUrl "/users/:user", "/#{namespace}/templates/user", "UserController"
      @routeTemplateUrl "/401", "/#{namespace}/templates/401", "MainController"

      @routeTemplateUrl "/", "/#{namespace}/templates/projects", "PredictController"
      @routeTemplateUrl "/dispatch/:user/:project", "/#{namespace}/templates/projects", "DispatchController"

      # project model
      @routeTemplateUrl "/projects", "/#{namespace}/templates/projects", "ProjectsController"
      @routeTemplateUrl "/project/:user/:project", "/#{namespace}/templates/project", "ProjectController"

#      @routeTemplateUrl "/predict/:user/:project", "/#{namespace}/templates/predict", "PredictController"
      @routeTemplateUrl "/setting/:user/:project", "/#{namespace}/templates/setting", "SettingController"
      @routeTemplateUrl "/dashboard/:user/:project", "/#{namespace}/templates/dashboard", "DashboardController"
      @routeTemplateUrl "/inventory/:user/:project", "/#{namespace}/templates/inventory", "InventoryController"
      @routeTemplateUrl "/station-setting/:user/:project", "/#{namespace}/templates/station_setting", "StationSettingController"
      @routeTemplateUrl "/event-manager/:user/:project", "/#{namespace}/templates/alarm", "AlarmController"
      @routeTemplateUrl "/monitoring/:user/:project", "/#{namespace}/templates/monitoring", "MonitoringController"

      @routeTemplateUrl "/user-manager/:user/:project", "/#{namespace}/templates/user_manager", "UserManagerController"
      @routeTemplateUrl "/user-management/:user/:project", "/#{namespace}/templates/user_management", "UserManagementController"
      @routeTemplateUrl "/distribute/:user/:project", "/#{namespace}/templates/distribute", "DistributeController"
      @routeTemplateUrl "/graphicac/:user/:project", "/#{namespace}/templates/graphicac", "GraphicacController"
      @routeTemplateUrl "/link/:user/:project", "/#{namespace}/templates/link", "LinkController"
      @routeTemplateUrl "/notification/:user/:project", "/#{namespace}/templates/notification", "NotificationController"
      @routeTemplateUrl "/asset-report/:user/:project", "/#{namespace}/templates/asset_report", "AssetReportController"
      @routeTemplateUrl "/user-info/:user/:project", "/#{namespace}/templates/user_info", "UserInfoController"
      @routeTemplateUrl "/alarm-report/:user/:project", "/#{namespace}/templates/alarm_report", "AlarmReportController"
      @routeTemplateUrl "/inspect/:user/:project", "/#{namespace}/templates/inspect", "InspectController"
      @routeTemplateUrl "/job/:user/:project", "/#{namespace}/templates/job", "JobController"
      @routeTemplateUrl "/knowledge/:user/:project", "/#{namespace}/templates/knowledge", "KnowledgeController"
      @routeTemplateUrl "/log/:user/:project", "/#{namespace}/templates/log", "LogController"
      @routeTemplateUrl "/signal-report/:user/:project", "/#{namespace}/templates/signal_report", "SignalReportController"
      @routeTemplateUrl "/station-3d/:user/:project", "/#{namespace}/templates/station_3d", "Station3dController"
      @routeTemplateUrl "/alarm-setting/:user/:project", "/#{namespace}/templates/alarm_setting", "AlarmSettingController"
      @routeTemplateUrl "/mobile/:user/:project", "/#{namespace}/templates/mobile", "MobileController"
      @routeTemplateUrl "/jobs/:user/:project", "/#{namespace}/templates/jobs", "JobsController"
      @routeTemplateUrl "/event-analysis/:user/:project", "/#{namespace}/templates/event_analysis", "EventAnalysisController"
      @routeTemplateUrl "/main-tasks/:user/:project", "/#{namespace}/templates/main_tasks", "MainTasksController"
      @routeTemplateUrl "/report-tasksum/:user/:project", "/#{namespace}/templates/report_tasksum", "ReportTasksumController"
      @routeTemplateUrl "/panoramic-overview/:user/:project", "/#{namespace}/templates/panoramic_overview", "PanoramicOverviewController"
      @routeTemplateUrl "/device-details/:user/:project/:station/:equipment", "/#{namespace}/templates/device_details", "DeviceDetailsController"
      @routeTemplateUrl "/station-info/:user/:project/:station", "/#{namespace}/templates/station_info", "StationInfoController"
      @routeTemplateUrl "/device-predict/:user/:project", "/#{namespace}/templates/device_predict", "DevicePredictController"
      @routeTemplateUrl "/log-system/:user/:project", "/#{namespace}/templates/log_system", "LogSystemController"
      @routeTemplateUrl "/authority/:user/:project", "/#{namespace}/templates/authority", "AuthorityController"
      @routeTemplateUrl "/user_roles/:user/:project", "/#{namespace}/templates/user_roles", "User_rolesController"
      @routeTemplateUrl "/work-overview/:user/:project", "/#{namespace}/templates/work_overview", "WorkOverviewController"
      @routeTemplateUrl "/work-calendar/:user/:project", "/#{namespace}/templates/work_calendar", "WorkCalendarController"
      @routeTemplateUrl "/work-manager/:user/:project", "/#{namespace}/templates/work_manager", "WorkManagerController"
      @routeTemplateUrl "/electric-calendar/:user/:project", "/#{namespace}/templates/electric_calendar", "ElectricCalendarController"
      @routeTemplateUrl "/predicttask-arrange/:user/:project", "/#{namespace}/templates/predicttask_arrange", "PredicttaskArrangeController"
      @routeTemplateUrl "/work-employee/:user/:project", "/#{namespace}/templates/work_employee", "WorkEmployeeController"
      @routeTemplateUrl "/inventory-list/:user/:project", "/#{namespace}/templates/inventory_list", "InventoryListController"
      @routeTemplateUrl "/report-stream-signal/:user/:project", "/#{namespace}/templates/report_stream_signal", "ReportStreamSignalController"
      @routeTemplateUrl "/test-page/:user/:project", "/#{namespace}/templates/test_page", "TestPageController"
      @routeTemplateUrl "/message-feedback/:user/:project", "/#{namespace}/templates/message_feedback", "MessageFeedbackController"
      @routeTemplateUrl "/stream-compare/:user/:project", "/#{namespace}/templates/stream_compare", "StreamCompareController"
      @routeTemplateUrl "/stream-test/:user/:project", "/#{namespace}/templates/stream_test", "StreamTestController"
      # {{route-register}}

      super


  exports =
    Router: Router