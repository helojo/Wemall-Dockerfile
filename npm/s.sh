#!/bin/bash
source ~/.bash_profile 
cd /root/wemall/nodejs/ && npm start &
cd /root/wemall/nodejs/ && npm run staticServ &
cd /root/wemall/ && go run main.go &
