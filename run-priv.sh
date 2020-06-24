#!/bin/bash

CW_WORKDIR="/cw_workspace"

if [ -z "$1" ]
then
      echo "Please supply a token for authentication!"
      exit 1
fi

if [ -z "$2" ]
then
	echo "Please supply a directory to work in."
	exit 1
fi

docker run -i -t -p 8888:8888 --privileged \
	--rm \
	--name "chipwhisperer" \
	-v /dev/bus/usb:/dev/bus/usb \
	-v ${2}:/$CW_WORKDIR \
	--env TOKEN=${1} \
    	suidroot/cw	
