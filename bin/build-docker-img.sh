#!/usr/bin/env bash

docker build -t logbot .
docker run -d -p 15000:15000 -e LOGBOT_NICK=genericnondescripguy -e LOGBOT_CHANNELS=#k0nsl,#trinity,#thehax -e LOGBOT_SERVER=ragnarok.k0nsl.org logbot
