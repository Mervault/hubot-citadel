try
  { Robot, Adapter, TextMessage, User } = require 'hubot'
catch
  prequire = require('parent-require')
  { Robot, Adapter, TextMessage, User } = prequire 'hubot'

{ MatrixClient, MemoryStorageProvider, AutojoinRoomsMixin } = require 'matrix-bot-sdk'
http = require 'http'
fetch = require 'node-fetch'

#Adapter = require('hubot').Adapter

class Citadel extends Adapter

  constructor: ->
    super
    @robot.logger.info "Constructor"

  send: (envelope, strings...) ->
    @robot.logger.info "Send"

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  authenticate: (server, user, password) ->
      @robot.logger.info "Authenticating to #{server} with #{user}:#{'*'.repeat(password.length)}"

      headers = { "Content-Type": "application/json" }
      
      #mystery to solve : which indentation are allowed for body ?
      body =
        {
          "type": "m.login.password",
          "identifier": {
            "type": "m.id.thirdparty",
            "medium": "email",
            "address": user
          },
          "password": password,
          "initial_device_display_name": "Zelda Bot v0.1"
        }

      fetch("https://#{server}/_matrix/client/r0/login", {
        method: 'post',
        headers: headers,
        body: JSON.stringify(body)
        } )
      .then (res) =>
        #@robot.logger.info (res.ok)
        #@robot.logger.info (res.status)
        #@robot.logger.info (res.statusText)
        #@robot.logger.debug (res.headers.raw())
        #@robot.logger.debug (res.headers.get('content-type'))
        res.json()
      .then (json) =>
        @robot.logger.debug "answer from authenticating server : ", json
        return json.access_token
      .catch (err) =>
        @robot.logger.error "When fetching server for token, catched following error : #{err}"
        undefined
      
  run: ->
    @robot.logger.info "Run"
    citadelAccessPoint = process.env.HUBOT_MATRIX_HOST_SERVER
    user = process.env.HUBOT_MATRIX_USER
    password = process.env.HUBOT_MATRIX_PASSWORD

    #authenticating to Citadel servers, register device, get access token
    token = @authenticate(citadelAccessPoint, user, password)
    @robot.logger.info "token retrieved in main function : #{token}"
    
    #authenticating to Matrix servers with the access token
    #matrixClient = new MatrixClient

    @emit "connected"
    userName = new User 1001, name: 'Sample User'
    message = new TextMessage userName, 'Some Sample Message', 'MSG-001'
    @robot.receive message


exports.use = (robot) ->
  new Citadel robot