###
* File: main
* User: Dow
* Date: 2014/10/8
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define [
  './module'

  './services/common-service'
  './services/predict-service'
  # {{service-file}}

  './controllers/predict-controller'
  './controllers/setting-controller'
  './controllers/dashboard-controller'
  './controllers/inventory-controller'
  './controllers/station-setting-controller'
  './controllers/alarm-controller'
  './controllers/monitoring-controller'
  './controllers/user-manager-controller'
  './controllers/user-management-controller'
  './controllers/distribute-controller'
  './controllers/graphicac-controller'
  './controllers/link-controller'
  './controllers/notification-controller'
  './controllers/asset-report-controller'
  './controllers/user-info-controller'
  './controllers/alarm-report-controller'
  './controllers/inspect-controller'
  './controllers/job-controller'
  './controllers/knowledge-controller'
  './controllers/log-controller'
  './controllers/signal-report-controller'
  './controllers/live-main-controller'
  './controllers/login-controller'
  './controllers/dispatch-controller'
  './controllers/station-3d-controller'
  './controllers/alarm-setting-controller'
  './controllers/mobile-controller'
  './controllers/jobs-controller'
  './controllers/event-analysis-controller'
  './controllers/main-tasks-controller'
  './controllers/report-tasksum-controller'
  './controllers/panoramic-overview-controller'
  './controllers/device-details-controller'
  './controllers/station-info-controller'
  './controllers/device-predict-controller'
  './controllers/log-system-controller'
  './controllers/authority-controller'
  './controllers/user_roles-controller'
  './controllers/work-overview-controller'
  './controllers/work-calendar-controller'
  './controllers/work-manager-controller'
  './controllers/electric-calendar-controller'
  './controllers/predicttask-arrange-controller'
  './controllers/work-employee-controller'
  './controllers/inventory-list-controller'
  './controllers/report-stream-signal-controller'
  './controllers/test-page-controller'
  './controllers/message-feedback-controller'
  './controllers/stream-compare-controller'
  './controllers/stream-test-controller'
  # {{controller-file}}

#  'graphic-directives'
  './directives/menu/component'
  './directives/menu-control/component'
  './directives/signal-gauge/component'
  './directives/custom-header/component'
  './directives/station-breadcrumbs/component'
  './directives/inventory-manage/component'
  './directives/header/component'
  
  './directives/station-manager/component'
  './directives/event-manager/component'
  './directives/event-statistic/component'
  './directives/event-statistic-chart/component'
  './directives/event-list/component'
  './directives/search-input/component'
  './directives/equipment-breadcrumbs/component'
  './directives/percent-gauge/component'
  './directives/alarm-number-box/component'
  './directives/signal-gauge-picker/component'
  './directives/equipment-info/component'
  './directives/user-manager/component'
  './directives/rotate-showing-model/component'
  './directives/func-devicemonitor/component'
  './directives/component-devicemonitor/component'
  './directives/graphicparamter-box/component'
  './directives/user-management/component'
  './directives/notification/component'
  './directives/alarm-link/component'
  './directives/station-visualization/component'
  './directives/visualization-tree/component'
  './directives/reporting-asset/component'
  './directives/user-personinfo/component'
  
  './directives/report-operations/component'
  './directives/report-historysignal/component'
  './directives/device-tree/component'
  './directives/grid-table/component'
  './directives/bar-or-line/component'
  './directives/drop-down/component'
  './directives/query-report/component'
  './directives/equipment-property/component'
  './directives/report-query-time/component'
  './directives/report-alarm-records/component'
  './directives/custom-dashboard/component'
  './directives/dashboard-header1/component'
  './directives/station-graphic/component'
  './directives/equipment-signals/component'
  './directives/alarm-severity-boxes/component'
  './directives/percent-pie/component'
  './directives/distribution-manager/component'
  './directives/signal-pie/component'
  './directives/station-environment/component'
  './directives/signal-real-value/component'
  './directives/acousto-optic-control/component'
  './directives/device-filter/component'
  './directives/station-tree/component'
  './directives/equip-lineorbar/component'
  './directives/monitoring/component'
  './directives/equipment-timefilter/component'
  './directives/component-line/component'
  './directives/alarm-setting/component'
  './directives/station-3d/component'
  './directives/component-maintasks/component'
  './directives/task-timeline/component'
  './directives/app-qrcode/component'
  './directives/component-tasksum/component'
  './directives/component-pie/component'
  './directives/work-button/component'
  './directives/alarms-monitoring/component'
  './directives/station-tree-with-count/component'
  './directives/station-video/component'
  './directives/equipment-statistic/component'
  './directives/import-assets/component'
  './directives/server-performanceinfo/component'
  './directives/event-analysis-chart/component'
  './directives/event-analysis/component'
  './directives/equipment-air/component'
  './directives/task-page/component'
  './directives/task-new-model/component'
  './directives/task-table/component'
  './directives/one-file-uploader/component'
  './directives/task-statistics-chart/component'
  
  
  './directives/three-quarter-pie/component'
  './directives/monitoring-leon/component'
  './directives/device-tree-leon/component'
  './directives/station-environmentyu/component'
  './directives/main-dashboard/component'
  './directives/map-header/component'
  './directives/device-overview/component'
  './directives/station-overview/component'
  './directives/panoramic-overview/component'
  './directives/scene-3d-component/component'
  './directives/station-device-status/component'
  './directives/wisdom-predict/component'
  './directives/device-details-component/component'
  './directives/device-temperature/component'
  './directives/device-state/component'
  './directives/device-information/component'
  './directives/bathtub-curve/component'
  './directives/station-info/component'
  './directives/device-predict/component'
  './directives/new-station-device-list/component'
  './directives/device-monitor/component'
  './directives/station-map/component'
  './directives/frequency-header/component'
  './directives/stream-data-chart/component'
  './directives/plugin-uploader/component'
  './directives/log-system/component'
  './directives/component-userroles/component'
  './directives/equipment-assets/component'
  './directives/station-key-signal/component'
  './directives/station-describe/component'
  './directives/station-alarm-summary/component'
  './directives/prediction-alarm/component'
  './directives/forecast-results-list/component'
  './directives/station-switch/component'
  './directives/station-device/component'
  './directives/device-main-signal/component'
  './directives/device-alarm-chart/component'
  './directives/device-stream-data-signal/component'
  './directives/device-configuration/component'
  './directives/device-3d-component/component'
  './directives/station-overview-map/component'
  './directives/opc-curve/component'
  './directives/component-rolesrights/component'
  './directives/station-map-predict/component'
  './directives/header-predict/component'
  './directives/stream-voice-curve/component'
  
  './directives/event-startlist/component'
  
  './directives/system-setting/component'
  './directives/ops-info/component'
  './directives/device-condition-chart/component'
  './directives/failure-rank-chart/component'
  './directives/order-situation/component'
  './directives/stream-current-curve/component'
  './directives/stream-shock-curve/component'

  './directives/comp-work-overview/component'
  './directives/task-statistic-title/component'
  './directives/defecttask-card/component'
  './directives/card-border/component'
  './directives/predicttask-card/component'
  './directives/capacity-bar/component'
  './directives/show-lines/component'
  './directives/bar-stack/component'
  './directives/ring-layers/component'
  './directives/user-groups/component'
  './directives/comp-workplan/component'
  './directives/comp-defectsetting/component'
  './directives/calendar-order/component'
  './directives/calendar-bar/component'
  './directives/station-device-list/component'
  
  './directives/pictorial-data-predict/component'
  './directives/inventory-list/component'
  './directives/stream-origin-current/component'
  './directives/stream-origin-voice/component'
  
  './directives/report-stream-signal/component'
  './directives/graphic-box/component'
  
  './directives/graphic2-box/component'
  
  './directives/graphic3-box/component'
  './directives/message-feedback/component'
  './directives/stream-curve-look/component'
  './directives/stream-origin-curve-look/component'
  './directives/stream-compare/component'
  './directives/single-query-date/component'
  './directives/pictorial-data/component'
  './directives/pictorial-data-device/component'

  './directives/stream-test/component'
  # {{directive-file}}


  # {{filter-file}}

], (
  module

  commonService
  predictService
  # {{service-namespace}}

  predictController
  settingController
  dashboardController
  inventoryController
  stationSettingController
  alarmController
  monitoringController
  userManagerController
  userManagementController
  distributeController
  graphicacController
  linkController
  notificationController
  assetReportController
  userInfoController
  alarmReportController
  inspectController
  jobController
  knowledgeController
  logController
  signalReportController
  liveMainController
  loginController
  dispatchController
  station3dController
  alarmSettingController
  mobileController
  jobsController
  eventAnalysisController
  mainTasksController
  reportTasksumController
  panoramicOverviewController
  deviceDetailsController
  stationInfoController
  devicePredictController
  logSystemController
  authorityController
  user_rolesController
  workOverviewController
  workCalendarController
  workManagerController
  electricCalendarController
  predicttaskArrangeController
  workEmployeeController
  inventoryListController
  reportStreamSignalController
  testPageController
  messageFeedbackController
  streamCompareController
  streamTestController
  # {{controller-namespace}}

#  graphicDirectives
  menuDirective
  menuControlDirective
  signalGaugeDirective
  customHeaderDirective
  stationBreadcrumbsDirective
  inventoryManageDirective
  headerDirective
  
  stationManagerDirective
  eventManagerDirective
  eventStatisticDirective
  eventStatisticChartDirective
  eventListDirective
  searchInputDirective
  equipmentBreadcrumbsDirective
  percentGaugeDirective
  alarmNumberBoxDirective
  signalGaugePickerDirective
  equipmentInfoDirective
  userManagerDirective
  rotateShowingModelDirective
  funcDevicemonitorDirective
  componentDevicemonitorDirective
  graphicparamterBoxDirective
  userManagementDirective
  notificationDirective
  alarmLinkDirective
  stationVisualizationDirective
  visualizationTreeDirective
  reportingAssetDirective
  userPersoninfoDirective
  
  reportOperationsDirective
  reportHistorysignalDirective
  deviceTreeDirective
  gridTableDirective
  barOrLineDirective
  dropDownDirective
  queryReportDirective
  equipmentPropertyDirective
  reportQueryTimeDirective
  reportAlarmRecordsDirective
  customDashboardDirective
  dashboardHeader1Directive
  stationGraphicDirective
  equipmentSignalsDirective
  alarmSeverityBoxesDirective
  percentPieDirective
  distributionManagerDirective
  signalPieDirective
  stationEnvironmentDirective
  signalRealValueDirective
  acoustoOpticControlDirective
  deviceFilterDirective
  stationTreeDirective
  equipLineorbarDirective
  monitoringDirective
  equipmentTimefilterDirective
  componentLineDirective
  alarmSettingDirective
  station3dDirective
  componentMaintasksDirective
  taskTimelineDirective
  appQrcodeDirective
  componentTasksumDirective
  componentPieDirective
  workButtonDirective
  alarmsMonitoringDirective
  stationTreeWithCountDirective
  stationVideoDirective
  equipmentStatisticDirective
  importAssetsDirective
  serverPerformanceinfoDirective
  eventAnalysisChartDirective
  eventAnalysisDirective
  equipmentAirDirective
  taskPageDirective
  taskNewModelDirective
  taskTableDirective
  oneFileUploaderDirective
  taskStatisticsChartDirective
  
  
  threeQuarterPieDirective
  monitoringLeonDirective
  deviceTreeLeonDirective
  stationEnvironmentyuDirective
  mainDashboardDirective
  mapHeaderDirective
  deviceOverviewDirective
  stationOverviewDirective
  panoramicOverviewDirective
  scene3dComponentDirective
  stationDeviceStatusDirective
  wisdomPredictDirective
  deviceDetailsComponentDirective
  deviceTemperatureDirective
  deviceStateDirective
  deviceInformationDirective
  bathtubCurveDirective
  stationInfoDirective
  devicePredictDirective
  newStationDeviceListDirective
  deviceMonitorDirective
  stationMapDirective
  frequencyHeaderDirective
  streamDataChartDirective
  pluginUploaderDirective
  logSystemDirective
  componentUserrolesDirective
  equipmentAssetsDirective
  stationKeySignalDirective
  stationDescribeDirective
  stationAlarmSummaryDirective
  predictionAlarmDirective
  forecastResultsListDirective
  stationSwitchDirective
  stationDeviceDirective
  deviceMainSignalDirective
  deviceAlarmChartDirective
  deviceStreamDataSignalDirective
  deviceConfigurationDirective
  device3dComponentDirective
  stationOverviewMapDirective
  opcCurveDirective
  componentRolesrightsDirective
  stationMapPredictDirective
  headerPredictDirective

  streamVoiceCurveDirective

  eventStartlistDirective
  
  systemSettingDirective
  opsInfoDirective
  deviceConditionChartDirective
  failureRankChartDirective
  orderSituationDirective
  streamCurrentCurveDirective
  streamShockCurveDirective

  compWorkOverviewDirective
  taskStatisticTitleDirective
  defecttaskCardDirective
  cardBorderDirective
  predicttaskCardDirective
  capacityBarDirective
  showLinesDirective
  barStackDirective
  ringLayersDirective
  userGroupsDirective
  compWorkplanDirective
  compDefectsettingDirective
  calendarOrderDirective
  calendarBarDirective
  stationDeviceListDirective
  
  pictorialDataPredictDirective
  inventoryListDirective
  streamOriginCurrentDirective
  streamOriginVoiceDirective
  
  reportStreamSignalDirective
  graphicBoxDirective
  
  graphic2BoxDirective
  
  graphic3BoxDirective
  messageFeedbackDirective
  streamCurveLookDirective
  streamOriginCurveLookDirective

  streamCompareDirective
  singleQueryDateDirective

  pictorialDataDirective
  pictorialDataDeviceDirective

  streamTestDirective
  # {{directive-namespace}}

  # {{filter-namespace}}

) ->
  # services
  module.service 'commonService', ['$rootScope', '$http', 'modelEngine','liveService', 'reportingService', 'uploadService', commonService.CommonService]

  module.service 'predictService', ['$rootScope', 'httpService', ($rootScope, httpService) ->
    new predictService.PredictService $rootScope, httpService
  ]
  # {{service-register}}

  # controllers
  # add $timeout and modelEngine
  createModelController20 = (name, Controller, type, key, title) ->
    module.controller name, ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$timeout', 'modelManager', 'modelEngine', 'uploadService',
      ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService) ->
        options =
          type: type
          key: key
          title: title
          uploadUrl: setting.urls.uploadUrl
          fileUrl: setting.urls.fileUrl
          url: setting.urls[type]

        new Controller $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options
    ]

  # add predict service
  createModelController21 = (name, Controller, type, key, title) ->
    module.controller name, ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$timeout', 'modelManager', 'modelEngine', 'uploadService', 'predictService'
      ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, predictService) ->
        options =
          type: type
          key: key
          title: title
          uploadUrl: setting.urls.uploadUrl
          fileUrl: setting.urls.fileUrl
          url: setting.urls[type]

        new Controller $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, predictService, options
    ]

  createModelController21 'PredictController', predictController.PredictController, 'project', ['user', 'project'], '预测性运维'
  createModelController20 'SettingController', settingController.SettingController, 'project', ['user', 'project'], '系统设置'
  createModelController20 'DashboardController', dashboardController.DashboardController, 'project', ['user', 'project'], 'Dashboard'
  createModelController20 'InventoryController', inventoryController.InventoryController, 'project', ['user', 'project'], '资产管理'
  createModelController20 'StationSettingController', stationSettingController.StationSettingController, 'project', ['user', 'project'], '站点管理'
  createModelController20 'AlarmController', alarmController.AlarmController, 'project', ['user', 'project'], '告警管理'
  createModelController20 'MonitoringController', monitoringController.MonitoringController, 'project', ['user', 'project'], '实时监控'
  createModelController20 'UserManagerController', userManagerController.UserManagerController, 'project', ['user', 'project'], '门禁用户'
  createModelController20 'UserManagementController', userManagementController.UserManagementController, 'project', ['user', 'project'], 'UserManagement'
  createModelController20 'DistributeController', distributeController.DistributeController, 'project', ['user', 'project'], '配电管理'
  createModelController20 'GraphicacController', graphicacController.GraphicacController, 'project', ['user', 'project'], '空调群控'
  createModelController20 'LinkController', linkController.LinkController, 'project', ['user', 'project'], '联动管理'
  createModelController20 'NotificationController', notificationController.NotificationController, 'project', ['user', 'project'], '告警通知'
  createModelController20 'AssetReportController', assetReportController.AssetReportController, 'project', ['user', 'project'], '资产报表'
  createModelController20 'UserInfoController', userInfoController.UserInfoController, 'project', ['user', 'project'], '用户管理'
  createModelController20 'AlarmReportController', alarmReportController.AlarmReportController, 'project', ['user', 'project'], '告警记录'
  createModelController20 'InspectController', inspectController.InspectController, 'project', ['user', 'project'], '巡检管理'
  createModelController20 'JobController', jobController.JobController, 'project', ['user', 'project'], '工单管理'
  createModelController20 'KnowledgeController', knowledgeController.KnowledgeController, 'project', ['user', 'project'], '知识库管理'
  createModelController20 'LogController', logController.LogController, 'project', ['user', 'project'], '日志管理'
  createModelController20 'SignalReportController', signalReportController.SignalReportController, 'project', ['user', 'project'], '历史数据'

  module.controller 'LiveMainController', ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$translate', 'storage', 'authService', 'liveService', 'modelManager', 'modelEngine', '$filter', liveMainController.LiveMainController]
  module.controller 'LoginController', ['$scope', '$rootScope', '$routeParams', '$location', '$window', 'authService', 'storage', loginController.LoginController]
  createModelController20 'DispatchController', dispatchController.DispatchController, 'project', ['user', 'project'], 'Dispatch'
  createModelController20 'Station3dController', station3dController.Station3dController, 'project', ['user', 'project'], '3D呈现'
  createModelController20 'AlarmSettingController', alarmSettingController.AlarmSettingController, 'project', ['user', 'project'], '告警设置'
  createModelController20 'MobileController', mobileController.MobileController, 'project', ['user', 'project'], '移动APP'
  createModelController20 'JobsController', jobsController.JobsController, 'project', ['user', 'project'], '工单管理'
  createModelController20 'EventAnalysisController', eventAnalysisController.EventAnalysisController, 'project', ['user', 'project'], 'EventAnalysis'
  createModelController20 'MainTasksController', mainTasksController.MainTasksController, 'project', ['user', 'project'], 'MainTasks'
  createModelController20 'ReportTasksumController', reportTasksumController.ReportTasksumController, 'project', ['user', 'project'], 'ReportTasksum'
  createModelController20 'PanoramicOverviewController', panoramicOverviewController.PanoramicOverviewController, 'project', ['user', 'project'], 'PanoramicOverview'
  createModelController20 'DeviceDetailsController', deviceDetailsController.DeviceDetailsController, 'project', ['user', 'project','station','equipment'], 'DeviceDetails'
  createModelController20 'StationInfoController', stationInfoController.StationInfoController, 'project', ['user', 'project','station'], 'StationInfo'
  createModelController20 'DevicePredictController', devicePredictController.DevicePredictController, 'project', ['user', 'project'], 'DevicePredict'
  createModelController20 'LogSystemController', logSystemController.LogSystemController, 'project', ['user', 'project'], 'LogSystem'
  createModelController20 'AuthorityController', authorityController.AuthorityController, 'project', ['user', 'project'], 'Authority'
  createModelController20 'User_rolesController', user_rolesController.User_rolesController, 'project', ['user', 'project'], 'User_roles'
  createModelController20 'WorkOverviewController', workOverviewController.WorkOverviewController, 'project', ['user', 'project'], 'WorkOverview'
  createModelController20 'WorkCalendarController', workCalendarController.WorkCalendarController, 'project', ['user', 'project'], 'WorkCalendar'
  createModelController20 'WorkManagerController', workManagerController.WorkManagerController, 'project', ['user', 'project'], 'WorkManager'
  createModelController20 'ElectricCalendarController', electricCalendarController.ElectricCalendarController, 'project', ['user', 'project'], 'ElectricCalendar'
  createModelController20 'PredicttaskArrangeController', predicttaskArrangeController.PredicttaskArrangeController, 'project', ['user', 'project'], 'PredicttaskArrange'
  createModelController20 'WorkEmployeeController', workEmployeeController.WorkEmployeeController, 'project', ['user', 'project'], 'WorkEmployee'
  createModelController20 'InventoryListController', inventoryListController.InventoryListController, 'project', ['user', 'project'], 'InventoryList'
  createModelController20 'ReportStreamSignalController', reportStreamSignalController.ReportStreamSignalController, 'project', ['user', 'project'], 'ReportStreamSignal'
  createModelController20 'TestPageController', testPageController.TestPageController, 'project', ['user', 'project'], 'TestPage'
  createModelController20 'MessageFeedbackController', messageFeedbackController.MessageFeedbackController, 'project', ['user', 'project'], 'MessageFeedback'
  createModelController20 'StreamCompareController', streamCompareController.StreamCompareController, 'project', ['user', 'project'], 'StreamCompare'
  createModelController20 'StreamTestController', streamTestController.StreamTestController, 'project', ['user', 'project'], 'StreamTest'
  # {{controller-register}}

  # directives
#  module.directive 'graphicViewer', ['$window', '$timeout', 'modelManager', 'storage', graphicDirectives.GraphicViewerDirective]
#  module.directive 'graphicPlayer', ['$window', '$timeout', '$compile', 'modelManager', 'liveService', 'storage', graphicDirectives.GraphicPlayerDirective]
#  module.directive 'elementPopover', ['$timeout', '$compile', graphicDirectives.ElementPopoverDirective]
  # {{directive-register}}

  createDirective = (name, Directive) ->
    module.directive name, ['$timeout', '$window', '$compile', '$routeParams', 'commonService', ($timeout, $window, $compile, $routeParams, commonService)->
      new Directive $timeout, $window, $compile, $routeParams, commonService
    ]
  createDirective 'menu', menuDirective.MenuDirective
  createDirective 'menuControl', menuControlDirective.MenuControlDirective
  createDirective 'signalGauge', signalGaugeDirective.SignalGaugeDirective
  createDirective 'customHeader', customHeaderDirective.CustomHeaderDirective
  
  
  createDirective 'stationBreadcrumbs', stationBreadcrumbsDirective.StationBreadcrumbsDirective
  
  createDirective 'inventoryManage', inventoryManageDirective.InventoryManageDirective
  createDirective 'header', headerDirective.HeaderDirective
  
  createDirective 'stationManager', stationManagerDirective.StationManagerDirective
  createDirective 'eventManager', eventManagerDirective.EventManagerDirective
  createDirective 'eventStatistic', eventStatisticDirective.EventStatisticDirective
  createDirective 'eventStatisticChart', eventStatisticChartDirective.EventStatisticChartDirective
  createDirective 'eventList', eventListDirective.EventListDirective
  createDirective 'searchInput', searchInputDirective.SearchInputDirective
  
  
  
  createDirective 'equipmentBreadcrumbs', equipmentBreadcrumbsDirective.EquipmentBreadcrumbsDirective
  createDirective 'percentGauge', percentGaugeDirective.PercentGaugeDirective
  
  
  
  createDirective 'alarmNumberBox', alarmNumberBoxDirective.AlarmNumberBoxDirective
  
  
  createDirective 'signalGaugePicker', signalGaugePickerDirective.SignalGaugePickerDirective
  
  createDirective 'equipmentInfo', equipmentInfoDirective.EquipmentInfoDirective
  createDirective 'userManager', userManagerDirective.UserManagerDirective
  createDirective 'rotateShowingModel', rotateShowingModelDirective.RotateShowingModelDirective
  createDirective 'funcDevicemonitor', funcDevicemonitorDirective.FuncDevicemonitorDirective
  createDirective 'componentDevicemonitor', componentDevicemonitorDirective.ComponentDevicemonitorDirective
  createDirective 'graphicparamterBox', graphicparamterBoxDirective.GraphicparamterBoxDirective
  createDirective 'userManagement', userManagementDirective.UserManagementDirective
  
  createDirective 'notification', notificationDirective.NotificationDirective
  createDirective 'alarmLink', alarmLinkDirective.AlarmLinkDirective
  createDirective 'stationVisualization', stationVisualizationDirective.StationVisualizationDirective
  createDirective 'visualizationTree', visualizationTreeDirective.VisualizationTreeDirective
  createDirective 'reportingAsset', reportingAssetDirective.ReportingAssetDirective
  createDirective 'userPersoninfo', userPersoninfoDirective.UserPersoninfoDirective
  
  createDirective 'reportOperations', reportOperationsDirective.ReportOperationsDirective
  createDirective 'reportHistorysignal', reportHistorysignalDirective.ReportHistorysignalDirective
  createDirective 'deviceTree', deviceTreeDirective.DeviceTreeDirective
  createDirective 'gridTable', gridTableDirective.GridTableDirective
  createDirective 'barOrLine', barOrLineDirective.BarOrLineDirective
  createDirective 'dropDown', dropDownDirective.DropDownDirective
  
  
  createDirective 'queryReport', queryReportDirective.QueryReportDirective
  createDirective 'equipmentProperty', equipmentPropertyDirective.EquipmentPropertyDirective
  
  
  createDirective 'reportQueryTime', reportQueryTimeDirective.ReportQueryTimeDirective
  createDirective 'reportAlarmRecords', reportAlarmRecordsDirective.ReportAlarmRecordsDirective
  createDirective 'customDashboard', customDashboardDirective.CustomDashboardDirective
  createDirective 'dashboardHeader1', dashboardHeader1Directive.DashboardHeader1Directive
  createDirective 'stationGraphic', stationGraphicDirective.StationGraphicDirective
  
  createDirective 'equipmentSignals', equipmentSignalsDirective.EquipmentSignalsDirective
  createDirective 'alarmSeverityBoxes', alarmSeverityBoxesDirective.AlarmSeverityBoxesDirective
  
  
  createDirective 'percentPie', percentPieDirective.PercentPieDirective
  createDirective 'distributionManager', distributionManagerDirective.DistributionManagerDirective
  createDirective 'signalPie', signalPieDirective.SignalPieDirective
  createDirective 'stationEnvironment', stationEnvironmentDirective.StationEnvironmentDirective
  createDirective 'signalRealValue', signalRealValueDirective.SignalRealValueDirective
  createDirective 'acoustoOpticControl', acoustoOpticControlDirective.AcoustoOpticControlDirective
  createDirective 'deviceFilter', deviceFilterDirective.DeviceFilterDirective
  createDirective 'stationTree', stationTreeDirective.StationTreeDirective
  createDirective 'equipLineorbar', equipLineorbarDirective.EquipLineorbarDirective
  
  createDirective 'monitoring', monitoringDirective.MonitoringDirective
  createDirective 'equipmentTimefilter', equipmentTimefilterDirective.EquipmentTimefilterDirective
  createDirective 'componentLine', componentLineDirective.ComponentLineDirective
  createDirective 'alarmSetting', alarmSettingDirective.AlarmSettingDirective
  createDirective 'station3d', station3dDirective.Station3dDirective
  createDirective 'componentMaintasks', componentMaintasksDirective.ComponentMaintasksDirective
  createDirective 'taskTimeline', taskTimelineDirective.TaskTimelineDirective
  
  
  
  createDirective 'appQrcode', appQrcodeDirective.AppQrcodeDirective
  createDirective 'componentTasksum', componentTasksumDirective.ComponentTasksumDirective
  createDirective 'componentPie', componentPieDirective.ComponentPieDirective
  createDirective 'workButton', workButtonDirective.WorkButtonDirective
  createDirective 'alarmsMonitoring', alarmsMonitoringDirective.AlarmsMonitoringDirective
  createDirective 'stationTreeWithCount', stationTreeWithCountDirective.StationTreeWithCountDirective
  createDirective 'stationVideo', stationVideoDirective.StationVideoDirective
  createDirective 'equipmentStatistic', equipmentStatisticDirective.EquipmentStatisticDirective
  
  
  
  
  
  createDirective 'importAssets', importAssetsDirective.ImportAssetsDirective
  createDirective 'serverPerformanceinfo', serverPerformanceinfoDirective.ServerPerformanceinfoDirective

  createDirective 'eventAnalysisChart', eventAnalysisChartDirective.EventAnalysisChartDirective
  createDirective 'eventAnalysis', eventAnalysisDirective.EventAnalysisDirective

  createDirective 'equipmentAir', equipmentAirDirective.EquipmentAirDirective

  
  
  
  createDirective 'taskPage', taskPageDirective.TaskPageDirective
  createDirective 'taskNewModel', taskNewModelDirective.TaskNewModelDirective
  createDirective 'taskTable', taskTableDirective.TaskTableDirective
  createDirective 'oneFileUploader', oneFileUploaderDirective.OneFileUploaderDirective
  
  createDirective 'taskStatisticsChart', taskStatisticsChartDirective.TaskStatisticsChartDirective
  
  
  
  
  createDirective 'threeQuarterPie', threeQuarterPieDirective.ThreeQuarterPieDirective
  createDirective 'monitoringLeon', monitoringLeonDirective.MonitoringLeonDirective
  createDirective 'deviceTreeLeon', deviceTreeLeonDirective.DeviceTreeLeonDirective
  createDirective 'stationEnvironmentyu', stationEnvironmentyuDirective.StationEnvironmentyuDirective
  createDirective 'mainDashboard', mainDashboardDirective.MainDashboardDirective
  createDirective 'mapHeader', mapHeaderDirective.MapHeaderDirective
  
  createDirective 'deviceOverview', deviceOverviewDirective.DeviceOverviewDirective
  createDirective 'stationOverview', stationOverviewDirective.StationOverviewDirective
  createDirective 'panoramicOverview', panoramicOverviewDirective.PanoramicOverviewDirective
  createDirective 'scene3dComponent', scene3dComponentDirective.Scene3dComponentDirective
  
  createDirective 'stationDeviceStatus', stationDeviceStatusDirective.StationDeviceStatusDirective
  createDirective 'wisdomPredict', wisdomPredictDirective.WisdomPredictDirective
  createDirective 'deviceDetailsComponent', deviceDetailsComponentDirective.DeviceDetailsComponentDirective
  
  createDirective 'deviceTemperature', deviceTemperatureDirective.DeviceTemperatureDirective
  createDirective 'deviceState', deviceStateDirective.DeviceStateDirective
  createDirective 'deviceInformation', deviceInformationDirective.DeviceInformationDirective
  createDirective 'bathtubCurve', bathtubCurveDirective.BathtubCurveDirective
  createDirective 'stationInfo', stationInfoDirective.StationInfoDirective
  createDirective 'devicePredict', devicePredictDirective.DevicePredictDirective
  createDirective 'newStationDeviceList', newStationDeviceListDirective.NewStationDeviceListDirective
  createDirective 'deviceMonitor', deviceMonitorDirective.DeviceMonitorDirective
  createDirective 'stationMap', stationMapDirective.StationMapDirective
  createDirective 'frequencyHeader', frequencyHeaderDirective.FrequencyHeaderDirective
  createDirective 'streamDataChart', streamDataChartDirective.StreamDataChartDirective
  createDirective 'pluginUploader', pluginUploaderDirective.PluginUploaderDirective
  createDirective 'logSystem', logSystemDirective.LogSystemDirective
  createDirective 'componentUserroles', componentUserrolesDirective.ComponentUserrolesDirective
  createDirective 'equipmentAssets', equipmentAssetsDirective.EquipmentAssetsDirective
  createDirective 'stationKeySignal', stationKeySignalDirective.StationKeySignalDirective
  createDirective 'stationDescribe', stationDescribeDirective.StationDescribeDirective
  createDirective 'stationAlarmSummary', stationAlarmSummaryDirective.StationAlarmSummaryDirective
  createDirective 'predictionAlarm', predictionAlarmDirective.PredictionAlarmDirective
  createDirective 'forecastResultsList', forecastResultsListDirective.ForecastResultsListDirective
  createDirective 'stationSwitch', stationSwitchDirective.StationSwitchDirective
  createDirective 'stationDevice', stationDeviceDirective.StationDeviceDirective
  createDirective 'deviceMainSignal', deviceMainSignalDirective.DeviceMainSignalDirective
  createDirective 'deviceAlarmChart', deviceAlarmChartDirective.DeviceAlarmChartDirective
  createDirective 'deviceStreamDataSignal', deviceStreamDataSignalDirective.DeviceStreamDataSignalDirective
  createDirective 'deviceConfiguration', deviceConfigurationDirective.DeviceConfigurationDirective
  createDirective 'device3dComponent', device3dComponentDirective.Device3dComponentDirective
  createDirective 'stationOverviewMap', stationOverviewMapDirective.StationOverviewMapDirective
  createDirective 'opcCurve', opcCurveDirective.OpcCurveDirective
  createDirective 'componentRolesrights', componentRolesrightsDirective.ComponentRolesrightsDirective
  
  createDirective 'stationMapPredict', stationMapPredictDirective.StationMapPredictDirective
  createDirective 'headerPredict', headerPredictDirective.HeaderPredictDirective

  createDirective 'streamVoiceCurve', streamVoiceCurveDirective.StreamVoiceCurveDirective

  
  createDirective 'eventStartlist', eventStartlistDirective.EventStartlistDirective
  
  createDirective 'systemSetting', systemSettingDirective.SystemSettingDirective
  createDirective 'opsInfo', opsInfoDirective.OpsInfoDirective
  createDirective 'deviceConditionChart', deviceConditionChartDirective.DeviceConditionChartDirective
  createDirective 'failureRankChart', failureRankChartDirective.FailureRankChartDirective
  createDirective 'orderSituation', orderSituationDirective.OrderSituationDirective

  createDirective 'streamCurrentCurve', streamCurrentCurveDirective.StreamCurrentCurveDirective
  createDirective 'streamShockCurve', streamShockCurveDirective.StreamShockCurveDirective

  

  createDirective 'compWorkOverview', compWorkOverviewDirective.CompWorkOverviewDirective
  createDirective 'taskStatisticTitle', taskStatisticTitleDirective.TaskStatisticTitleDirective
  createDirective 'defecttaskCard', defecttaskCardDirective.DefecttaskCardDirective
  createDirective 'cardBorder', cardBorderDirective.CardBorderDirective
  createDirective 'predicttaskCard', predicttaskCardDirective.PredicttaskCardDirective
  createDirective 'capacityBar', capacityBarDirective.CapacityBarDirective
  createDirective 'showLines', showLinesDirective.ShowLinesDirective
  createDirective 'barStack', barStackDirective.BarStackDirective
  createDirective 'ringLayers', ringLayersDirective.RingLayersDirective
  createDirective 'userGroups', userGroupsDirective.UserGroupsDirective
  createDirective 'compWorkplan', compWorkplanDirective.CompWorkplanDirective
  createDirective 'compDefectsetting', compDefectsettingDirective.CompDefectsettingDirective
  createDirective 'calendarOrder', calendarOrderDirective.CalendarOrderDirective
  createDirective 'calendarBar', calendarBarDirective.CalendarBarDirective
  createDirective 'stationDeviceList', stationDeviceListDirective.StationDeviceListDirective
  
  createDirective 'pictorialDataPredict', pictorialDataPredictDirective.PictorialDataPredictDirective
  createDirective 'inventoryList', inventoryListDirective.InventoryListDirective
  createDirective 'streamOriginCurrent', streamOriginCurrentDirective.StreamOriginCurrentDirective
  createDirective 'streamOriginVoice', streamOriginVoiceDirective.StreamOriginVoiceDirective
  
  createDirective 'reportStreamSignal', reportStreamSignalDirective.ReportStreamSignalDirective
  createDirective 'graphicBox', graphicBoxDirective.GraphicBoxDirective
  
  createDirective 'graphic2Box', graphic2BoxDirective.Graphic2BoxDirective
  
  createDirective 'graphic3Box', graphic3BoxDirective.Graphic3BoxDirective
  createDirective 'messageFeedback', messageFeedbackDirective.MessageFeedbackDirective
  createDirective 'streamCurveLook', streamCurveLookDirective.StreamCurveLookDirective
  createDirective 'streamOriginCurveLook', streamOriginCurveLookDirective.StreamOriginCurveLookDirective

  createDirective 'streamCompare', streamCompareDirective.StreamCompareDirective
  createDirective 'singleQueryDate', singleQueryDateDirective.SingleQueryDateDirective

  createDirective 'pictorialData', pictorialDataDirective.PictorialDataDirective
  createDirective 'pictorialDataDevice', pictorialDataDeviceDirective.PictorialDataDeviceDirective

  createDirective 'streamTest', streamTestDirective.StreamTestDirective
  # {{component-register}}

  #filters
  # {{filter-register}}

