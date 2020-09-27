data = require 'clc.foundation.data'

setting = require '../../index-setting.json'
#svc = require '../../app/services/predict/calculation-service'
#usv = require '../../app/services/predict/u-service'
##启动tus服务
#tusclient=require 'clc.foundation/app/svc/tus-client'
#tusclientsetting = require 'clc.foundation/tus-setting.json'
# 启动auto-download服务
adsv = require '../../app/services/predict/auto-download-service'
afsv = require '../../app/services/predict/auto-file-service'

connection = new data.MongodbConnection setting.mongodb
connection.start()

#calculationService = new svc.CalculationService setting
#calculationService.start()

#uService = new usv.UService setting
#uService.start()

adService = new adsv.AutoDownloadService setting
adService.start()

#afService = new afsv.AutoFileService setting
#afService.start()
