try
  { Robot, Adapter, TextMessage, User } = require 'hubot'
catch
  prequire = require('parent-require')
  { Robot, Adapter, TextMessage, User } = prequire 'hubot'

{ MatrixClient, SimpleFsStorageProvider, AutojoinRoomsMixin } = require 'matrix-bot-sdk'
http = require 'http'
fetch = require 'node-fetch'

class Citadel extends Adapter

  constructor: ->
    super
    @robot.logger.info "Constructor"

  send: (envelope, strings...) ->
    @robot.logger.info "Send ", envelope.message, " ", envelope.room, " ", envelope.user
    strings = [].slice.call(arguments, 1)
    return if (strings.length == 0)
    @robot.logger.debug "Send this message ", strings[0]
    # using sendNotice here so that the type of the message is m.notice.
    # that way, the ’handleCommand’ callback can simply filter out m.notice to avoid
    # reacting on self posted messages. This is useful as long as the bot is
    # using the same user id as a human user
    @client.sendNotice envelope.room, strings[0]

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  authenticate: (server, user, password) ->
      @robot.logger.info "Authenticating to #{server} with #{user}:#{'*'.repeat(password.length)}"

      headers = { "Content-Type": "application/json" }
      
      #mystery to solve : which indentation are allowed for body ?
      #supposedly coffeescript would allow to avoid curly braces...
      body =
        {
          "type": "m.login.password",
          "identifier": {
            "type": "m.id.thirdparty",
            "medium": "email",
            "address": user
          },
          "password": password,
          "initial_device_display_name": "Zelda Bot v0.2"
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
    #asynchroneous call. using `.then` to catch the result of the request
    @authenticate(citadelAccessPoint, user, password)
    .then (token) =>
      @robot.logger.debug "token retrieved inside the promise response : ", token
      
      #initialising Matrix client with connexion parameters to Matrix servers with the access token
      @robot.logger.info 'Initialising Matrix session...'
      homeServer = "https://#{citadelAccessPoint}"
      storage = new SimpleFsStorageProvider("zelda-bot-storage.json")
      @client = new MatrixClient(homeServer, token, storage)
      
      #don’t know what this does…
      AutojoinRoomsMixin.setupOnClient(@client)

      #TODO figure out how to create message to send to hubot engine
      #definition of the callback to be used upon event on the rooms.
      #the callback get the message body and send it to hubot engine
      #some checks should be done. see examples on https://matrix.org/docs/projects/sdk/matrix-bot-sdk
      handleCommand = (roomId, event) =>
        @robot.logger.info event["sender"], " says ", event["content"]["body"]
        #author = event["sender"]
        #body = event["content"]["body"]
        #id = event["event_id"]
        #message = new TextMessage author, body, id
        #@robot.receive message

      #registering our callback for events of type "room.message"
      #see API documentation on https://matrix.org/docs/spec/client_server/latest#room-events
      @client.on('room.message', handleCommand)

      #connecting to the Matrix
      @client.start()
      .then () =>
        #we’re in ! let’s send an event to the robot engine
        #(is that really what’s done with the "@emit" ?)
        @robot.logger.info "bot connected to the Matrix"
        @emit "connected"

        #not sure what we’re supposed to do from here.
        #let’s try to return something to be catched afterward.
        undefined
      .then null, (err) =>
        @robot.logger.debug "error occured", err

exports.use = (robot) ->
  new Citadel robot