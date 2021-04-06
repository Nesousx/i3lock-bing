#!/usr/bin/env bash

#
# i3lock with Bing Wallpaper of the Day
# Denis G.
# March 19, 2021
# WIP
# TODO :
# * Test, test, test !
#
# Source for failsafe wallpaper : https://wallhaven.cc/w/13w91g

### Variables
today="`date +%d%m%y`"

base_url=http://bing.com
api_url=https://www.bing.com/HPImageArchive.aspx\?\&format\=js\&idx\=0\&mkt\=en-US\&n\=1

## Get API file locally to limit number of requests
api_file="/tmp/bing_api_$today.json"
curl -so $api_file $api_url

daily_suffix="`cat $api_file | jq -r '.images[]|.url'`"
copyright="`cat -s $api_file | jq -r '.images[]|.copyright'`"

lockscreen="/tmp/bing_$today.png"
bkp_lockscreen="$PWD/bkp_lockscreen.png"

## Download image only if not already there otherwise set failsafe lockscreen
if [ ! -f "$lockscreen" ]; then
	curl -so /tmp/bing_$today.jpg $base_url$daily_suffix
elif [ -f "$lockscreen" ]; then
	i3lock -i $lockscreen
	#echo "lockscreen from cache"
	exit 0
else
	i3lock -i $bkp_lockscreen
	#echo "bkp lockscreen"
	exit 0
fi

## Convert and add caption
convert /tmp/bing_$today.jpg -size 600x -background snow2 -fill gray44 -pointsize 24 caption:"$copyright" -gravity SouthEast -composite $lockscreen

## Set lockscreen
i3lock -i $lockscreen
#echo "new lockscreen"

## Clean up
if [ -f "/tmp/bing_$today.jpg" ]; then
	rm /tmp/bing_$today.jpg
fi
find /tmp -iname "bing_*" -type f -mtime +1 -delete 2>/dev/null
