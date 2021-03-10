#!/bin/bash

CW_WORKDIR="/cw_workspace"
#DOCKER_IMAGE="suidroot/cw:5.2"
DOCKER_IMAGE="suidroot/cw:latest"
CONTAINER_NAME="chipwhisperer"

COMMAND=$1

start_instance() {

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
		--name "$CONTAINER_NAME" \
		-v /dev/bus/usb:/dev/bus/usb \
		-v ${2}:/$CW_WORKDIR \
		--env TOKEN=${1} \
			$DOCKER_IMAGE

}

connect_instance() {
	echo "Connect to CW Docker"
	docker exec -it $CONTAINER_NAME /bin/bash
}


display_commands() {
	echo
    echo "Commands"
    echo "-------"
    echo "connect - connect to container"
    echo "start - Start CW Container"
	echo "		 <password> <directory>"

}

### Main ###
#
if [ "$#" -lt 1 ]; then
    echo "Must specify VM and action $#"
    error
fi

case $COMMAND in
	start)
		start_instance "$2" "$3"
		;;
	connect)
		connect_instance
		;;
	*)
		display_commands
		;;
esac
