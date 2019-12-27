#!/bin/bash

mode=$1

if [ "$mode" = "stop" ]; then
    echo -e "Stopping systemctls..."
    sudo systemctl stop nginx
    sudo systemctl stop mysqld
    sudo systemctl stop php-fpm
    sudo systemctl stop redis
    echo -e "!~Enjoy~!"
else
    if [ "$mode" = "start" ]; then
        echo -e "Starting systemctls..."
        sudo systemctl start nginx
        sudo systemctl start mysqld
        sudo systemctl start php-fpm
        sudo systemctl start redis
        echo -e "!~Enjoy~!"
    else
        if [ "$mode" = "reload" ]; then
            echo -e "Starting systemctls..."
            sudo systemctl reload nginx
            sudo systemctl restart mysqld
            sudo systemctl reload php-fpm && sudo systemctl restart php-fpm
            sudo systemctl restart redis
            echo -e "!~Enjoy~!"
        else
            if [ "$mode" = "restart" ]; then
                echo -e "Starting systemctls..."
                sudo systemctl restart nginx
                sudo systemctl restart mysqld
                sudo systemctl restart php-fpm
                sudo systemctl restart redis
                echo -e "!~Enjoy~!"
            else
                echo "Command Not Found. Possible Commands [ start|stop|restart|reload ]"
            fi
        fi
    fi
fi
