This is (or will be) a Hubot adapter for Citadel.
Heavily under work…

# Usage

## First things first : getting Hubot

Go checkout that : https://github.com/Mervault/zelda

Or follow the official Hubot documentation over there : https://hubot.github.com/

## Setting up hubot-citadel prototype

The following environment variables have to be defined prior starting Hubot :
* HUBOT_MATRIX_HOST_SERVER : address of citadel server
* HUBOT_MATRIX_USER : email address to be used as authentication
* HUBOT_MATRIX_PASSWORD : password to be used as authentication

The following environment variable can come in handy :
* HUBOT_LOG_LEVEL="debug"

And, writing this readme waaay later than the code, that environment variable purpose has been lost 
(but most probably linked to some weird dependency management between hubot and the adapter in its current non-packaged form) :
* PATH="node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH"

## installing the adapter in your Hubot
Read the doc. But not this one. Yet.