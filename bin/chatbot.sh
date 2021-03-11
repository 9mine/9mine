#!/bin/sh

TWITCH_TOKEN="$1"

test -z "$TWITCH_TOKEN" && {
  echo "Usage $0 TWITCH_TOKEN" 
  exit 1
}

EGGDROP_PASSWORD=aaa222

mkdir -p chatbot_eggdrop


docker run -ti \
	--name eggdrop \
	-p 3333:3333   \
	--rm -e NICK=btc_live -e SERVER=irc.chat.twitch.tv:+6697:"$TWITCH_TOKEN" \
	-v `pwd`/chatbot/eggdrop:/home/eggdrop/eggdrop/data \
 	eggdrop

(printf "\n$EGGDROP_PASSWORD\n.msg #btc_live printf test\n"; nc -ukl 0.0.0.0 6666) | nc localhost 3333
