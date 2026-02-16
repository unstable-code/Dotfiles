#!/bin/bash

today=$(date +'%m%d')
if [ $today == '0301' ]; then
    echo '삼일절'
elif [ $today == '0405' ]; then
    echo '식목일'
elif [ $today == '0606' ]; then
    echo '현충일'
elif [ $today == '0717' ]; then
    echo '제헌절'
elif [ $today == '0815' ]; then
    echo '광복절'
elif [ $today == '1003' ]; then
    echo '개천절'
elif [ $today == '1009' ]; then
    echo '한글날'
elif [ $today == '1225' ]; then
    echo '성탄절'
fi
