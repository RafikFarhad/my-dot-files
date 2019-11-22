#!/bin/bash

mode=$1

if [ "$mode" =  "stop" ]
then
    echo -e "Stopping systemctls..."
    sudo systemctl stop nginx 
    sudo systemctl stop mysql
    sudo systemctl php-fpm stop
    sudo systemctl stop redis-server 
    echo -e "!~Enjoy~!"
else if [ "$mode" = "start"  ]
then
    echo -e "Starting systemctls..."
    sudo systemctl start nginx
    sudo systemctl start mysql
    sudo systemctl start php-fpm
    sudo systemctl start redis-server
    echo -e "!~Enjoy~!"
else if [ "$mode" = "reload"  ]
then
    echo -e "Starting systemctls..."
    sudo systemctl reload nginx
    sudo systemctl reload mysql
    sudo systemctl reload php-fpm
    sudo systemctl reload redis-server
    echo -e "!~Enjoy~!"
else
    echo "Command Not Found. Possible Commands [ start|stop ]"
fi
fi

