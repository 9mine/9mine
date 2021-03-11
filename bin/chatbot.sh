#!/bin/sh
docker run -ti \
	--name eggdrop \
	-p 3333:3333   \
	--rm -e NICK=btc_live -e SERVER=irc.chat.twitch.tv:+6697:"oauth:dv3enm0ktlg3kqxb4p5tw42ak8gew4" \
	-v `pwd`/chatbot/eggdrop:/home/eggdrop/eggdrop/data \
 	eggdrop
