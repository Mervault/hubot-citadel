try
  {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot,Adapter,TextMessage,User} = prequire 'hubot'

{ MatrixClient, MemoryStorageProvider, AutojoinRoomsMixin } = require 'matrix-bot-sdk'
http = require 'http'

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
      @robot.logger.info "Authenticating to #{server} with #{user}:#{password}"

      #http.request {
      #  methode: "POST"
      #  host: "#{server}"
      #  path: "/_matrix/client/r0/login"
      #  auth: "#{user}:#{password}"
      #  }, (res) ->
      #  console.log res.satus res.statusText
      #  console.log res

  run: ->
    @robot.logger.info "Run"

    #authenticating to Citadel servers, to get back the access token
    @authenticate("address", "user", "password")

    #authenticating to Matrix servers with the access token
    #matrixClient = new MatrixClient

    @emit "connected"
    user = new User 1001, name: 'Sample User'
    message = new TextMessage user, 'Some Sample Message', 'MSG-001'
    @robot.receive message


exports.use = (robot) ->
  new Citadel robot