#!/bin/bash

mode=$1

if [ "$mode" =  "stop" ]
then
    echo -e "Stopping Services..."
    sudo service nginx stop 
    sudo service mysql stop
    sudo service php7.3-fpm stop
    sudo service redis-server stop
    echo -e "!~Enjoy~!"
else if [ "$mode" = "start"  ]
then
    echo -e "Starting Services..."
    sudo service nginx start
    sudo service mysql start
    sudo service php7.3-fpm start
    sudo service redis-server start
    echo -e "!~Enjoy~!"
else
    echo "Command Not Found. Possible Commands [ start|stop ]"
fi
fi

