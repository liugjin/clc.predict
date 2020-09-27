###
* File: 02_gateway
* User: Dow
* Date: 5/7/2015
* Desc: 
###

sm = require '../../app/services/predict/service-manager'

module.exports = ->
#  sm.startServicesSync ['register', 'configuration', 'predict']
  sm.startService ['register', 'configuration', 'predict']
