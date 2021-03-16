#!/usr/bin/env bash

# i3lock-bing
# March 16 2021, Denis G.
# Make this script pull Bing Wallpaper of the Day + caption
# and set it as lockscreen

# Shamelessly based on :
# author: Whizzzkid (me@nishantarora.in)
# source: https://gist.github.com/b00f/4561c9083622960f6b88bd2fc40a72d2 

# Get Wallpaper

# Base URL.
bing="http://www.bing.com"

# API end point.
api="/HPImageArchive.aspx?"

# Response Format (json|xml).
format="&format=js"

# For day (0=current; 1=yesterday... so on).
day="&idx=0"

# Market for image.
market="&mkt=en-US"

# API Constant (fetch how many).
const="&n=1"

# Image extension.
extn=".png"

# Size.
size="1920x1080"

# Collection Path.
path="/tmp/"

# Make it run just once (useful to run as a cron)
run_once=false
while getopts "1" opt; do
  case $opt in
    1 )
      run_once=true
      ;;
    \? )
      echo "Invalid option! usage: \"$0 -1\", to run once and exit"
      exit 1
      ;;
  esac
done

########################################################################
#### DO NOT EDIT BELOW THIS LINE #######################################
########################################################################

# Required Image Uri.
reqImg=$bing$api$format$day$market$const


# Logging.
echo "Pinging Bing API..."

# Fetching API response.
apiResp=$(curl -s $reqImg)
if [ $? -gt 0 ]; then
  echo "Ping failed!"
  exit 1
fi

# Default image URL in case the required is not available.
defImgURL=$bing$(echo $apiResp | grep -oP "url\":\"[^\"]*" | cut -d "\"" -f 3)

# Req image url (raw).
reqImgURL=$bing$(echo $apiResp | grep -oP "urlbase\":\"[^\"]*" | cut -d "\"" -f 3)"_"$size$extn

# Image copyright.
copyright=$(echo $apiResp | grep -oP "copyright\":\"[^\"]*" | cut -d "\"" -f 3)

wp=$(echo $apiResp | grep -oP "\"wp\":.*," | cut -d "," -f 1)

if [ "$wp" == "\"wp\":false" ] ; then
  reqImgURL=$defImgURL
fi

# Checking if reqImgURL exists.
if ! wget --quiet --spider $reqImgURL; then
  reqImgURL=$defImgURL
fi

# Logging.
#echo "Bing Image of the day: $reqImgURL"

# Getting Image Name.
imgName=${reqImgURL##*/}

# Create Path Dir.
mkdir -p $path

# Saving Image to collection.
curl -s -o $path$imgName $reqImgURL

# Logging.
#echo "Saving image to $path$imgName"

# Writing copyright.
#echo "$copyright"  > $path${imgName}".txt"
#echo "$copyright"

## Now my part !

## Create image for i3lock
lockscsreen=/tmp/lockscsreen.png

convert $path$imgName -size 600x -background snow2 -fill gray44 -pointsize 24 caption:"$copyright" -gravity SouthEast -composite $lockscsreen

## Run i3lock
i3lock -i $lockscsreen
