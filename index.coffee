###
* File: index
* User: Pu
* Date: 11/01/13
* Desc: 
###

setting = require './index-setting.json'

foundation = require 'clc.foundation'
web = require 'clc.foundation.web'

# start web server
server = new web.Server setting
server.start()

# start daemon
daemonOptions = setting.daemon
daemonOptions.mqtt ?= setting.mqtt

daemonService = new foundation.DaemonService daemonOptions
daemonService.start()



