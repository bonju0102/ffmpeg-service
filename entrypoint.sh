#!/bin/bash
# IAI ffmpeg-service Dockerfile entrypoint script
# Written by BonJu Huang <bonju.huang@gmail.com>
#
# This script will start ffmpeg and node services.
# It looks in common places for the files & executables it needs
# and thus should be compatible with major Linux distros.

################
# MAIN PROGRAM #
################

# Environment Variables
URL = $1
WS_PORT = $2

# Go to jsmpeg directory
cd /home/jsmpeg-master/

# Start Websocket
echo "Start Websocket..."
node websocket-relay.js supersecret 8081 $WS_PORT &

# Start ffmpeg streaming
echo "Start ffmpeg streaming..."
ffmpeg -rtsp_transport tcp -i $URL \
-vf "transpose=1" -f mpegts -codec:v mpeg1video -codec:a mp2 -r 20 http://localhost:8081/supersecret &

# Ensure we shutdown our services cleanly when we are told to stop
trap cleanup SIGTERM

# Stay in a loop to keep the container running
while :
do
    # perhaps output some stuff here or check ffmpeg & node are still running
    sleep 2
done
