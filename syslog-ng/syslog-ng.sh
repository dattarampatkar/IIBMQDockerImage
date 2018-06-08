#!/bin/bash

set -e

L_S_NAME="syslog-ng"

L_U_NAME="log1"
L_G_NAME="nglogs"
L_L_FILEPATH="/var/log/syslog-ng/$HOST/$YEAR-$MONTH-$DAY.syslog-ng.log"

export L_S_NAME="syslog-ng"

#echo $SYSLOG_SERVER_IP
#echo $SYSLOG_SERVER_PORT

#export SYSLOG_SERVER_IP=$SYSLOG_SERVER_IP
#export SYSLOG_SERVER_PORT=$SYSLOG_SERVER_PORT

config()
{
	echo "-----------------------------------------------------------------------------------"
	echo "  Configuring ${S_NAME} under ${U_NAME}@${G_NAME}..."
	echo "-----------------------------------------------------------------------------------"
	: ${SYSLOG_SERVER_IP?"ERROR: You need to set the MQ_QMGR_NAME environment variable"}
	: ${SYSLOG_SERVER_PORT?"ERROR: You need to set the MQ_QMGR_NAME environment variable"}
	sudo sed -e 's/\^SYSLOG_SERVER_IP\^/$SYSLOG_SERVER_IP/g' -i /etc/syslog-ng/conf.d/client.conf
	sudo sed -e 's/\^SYSLOG_SERVER_PORT\^/$SYSLOG_SERVER_PORT/g' -i /etc/syslog-ng/conf.d/client.conf
}


chkconfig()
{
        ${L_S_NAME} --version | grep ${L_S_NAME} | awk -F '{ print $1 }'
}

state()
{
        ps -ef | grep $L_S_NAME | wc -l
}

stop()
{
        echo "${L_S_NAME} will be stopped..."
        sudo service ${L_S_NAME} stop
}

monitor()
{
	ret=`ps -ef | grep syslog-ng | grep sbin | wc -l`
        # check if process is not already running and if not start one
        if [ "$ret" == "0" ]; then
                echo "${L_S_NAME} is not running, attempting start" 
                sudo service ${L_S_NAME} restart
                sleep 5
        fi

        # Loop until 
	ret=`ps -ef | grep syslog-ng | grep sbin | wc -l`
        while true; do         
            if [ "$ret" == "0" ]; then
                echo "${L_S_NAME} is not running, attempting restart" 
                sudo service ${L_S_NAME} restart
	    fi
	    sleep 5
        done

}

clientConfig.sh &
sleep 2

monitor      

wait

trap stop SIGTERM SIGKILL

echo "Exiting chk script..."
