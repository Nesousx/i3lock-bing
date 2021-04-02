#!/usr/bin/env bash

#
# i3lock with Bing Wallpaper of the Day
# Denis G.
# March 19, 2021
# WIP
# TODO :
# * Single call to API ;
#
# Source for failsafe wallpaper : https://wallhaven.cc/w/13w91g

### Variables
today="`date +%d%m%y`"

base_url=http://bing.com
api_url=https://www.bing.com/HPImageArchive.aspx\?\&format\=js\&idx\=0\&mkt\=en-US\&n\=1

daily_suffix="`curl -s $api_url | jq -r '.images[]|.url'`"
copyright="`curl -s $api_url | jq -r '.images[]|.copyright'`"

lockscreen="/tmp/bing_$today.png"
bkp_lockscreen="$PWD/bkp_lockscreen.png"

## Download image only if not already there otherwise set failsafe lockscreen
if [ ! -f "$lockscreen" ]; then
	curl -so /tmp/bing_$today.jpg $base_url$daily_suffix
elif [ -f "$lockscreen" ]; then
	i3lock -i $lockscreen
	exit 0
else
	i3lock -i $bkp_lockscreen
	exit 0
fi

## Convert and add caption
convert /tmp/bing_$today.jpg -size 600x -background snow2 -fill gray44 -pointsize 24 caption:"$copyright" -gravity SouthEast -composite $lockscreen

## Set lockscreen
i3lock -i $lockscreen

## Clean up
if [ -f "/tmp/bing_$today.jpg" ]; then
	rm /tmp/bing_$today.jpg
fi
