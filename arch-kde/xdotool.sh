#!/bin/sh

current=$(xdotool get_desktop)
go=$1
if [[ "$go" == 1 ]]; then
    if [[ "$current" == 0 ]]; then
        xdotool set_desktop 1
    elif [[ "$current" == 1 ]]; then
        xdotool set_desktop 0
    elif [[ "$current" == 2 ]]; then
        xdotool set_desktop 3
    else
        [[ "$current" == 3 ]]
        xdotool set_desktop 2
    fi
elif [[ "$go" == 2 ]]; then
    if [[ "$current" == 0 ]]; then
        xdotool set_desktop 2
    elif [[ "$current" == 1 ]]; then
        xdotool set_desktop 3
    elif [[ "$current" == 2 ]]; then
        xdotool set_desktop 0
    else
        [[ "$current" == 3 ]]
        xdotool set_desktop 1
    fi
fi
