#!/bin/bash

#set instance number
file="/var/instance"
if [ -d "$file" ] 
	then
		export INSTANCE_NUMBER=$(cat /var/instance/instno)
	else
		echo "$file not found. Creating instance number & saving in file..."
		mkdir -p /var/instance
		echo $(( $RANDOM % 100 + 1 )) > /var/instance/instno
		export INSTANCE_NUMBER=$(cat /var/instance/instno)
		chmod -R 0777 /var/instance/
fi
