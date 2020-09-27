###
 * File: routes
 * User: Dow
 * Date: 4/11/13
 * Desc: 
###

setting = require '../index-setting.json'
cr = require '../app/routers/predict/router'

module.exports = ->

  predictRouter = new cr.Router setting, @
  predictRouter.start()
