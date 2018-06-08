#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Add DataSource - 5092_ESB_DB
# For logging - 5092_ESB_LOG

. setenv.sh

set -e

stop()
{
	echo "----------------------------------------"
	echo "Stopping node $NODE_NAME..."
	sudo su - iibuser -c "mqsistop $NODE_NAME"
}

start()
{

	HOST_EXISTS=`grep $HOSTNAME /etc/hosts ; echo $? `
	if [ ${HOST_EXISTS} -ne 0 ]; then
	    echo cat /etc/hosts
	    cp /etc/hosts /tmp/hosts
	    echo "Adding hostname $HOSTNAME to /etc/hosts..."
	    sed "$ a 127.0.0.1 $HOSTNAME " -i /tmp/hosts
	    cp /tmp/hosts /etc/hosts
	    rm /tmp/hosts
	    cat /etc/hosts
	fi

	echo "----------------------------------------"
	sudo su - iibuser /opt/ibm/iib-10.0.0.3/iib version
	echo "----------------------------------------"

	NODE_EXISTS=`sudo su - iibuser -c mqsilist | grep $NODE_NAME > /dev/null ; echo $? `

	echo "Starting rsyslogd..."
	/usr/sbin/rsyslogd

	if [ ${NODE_EXISTS} -ne 0 ]; then
	    echo "----------------------------------------"
	    echo "Node $NODE_NAME does not exist..."
	    
		echo "First create queue required by the IIB on Default broker and provide authorization"
		sudo su - mqm -c "/usr/local/bin/mq_config_security.sh"
		
		echo "Creating node $NODE_NAME"
	    sudo su - iibuser -c "mqsicreatebroker ${NODE_NAME} -q ${MQ_QMGR_NAME}"
				
		iib_config.sh
		
		echo "Enabling Global Cache on the ${NODE_NAME} on default port"
		sudo su - iibuser -c "mqsichangebroker $NODE_NAME -b default"
	    echo "Starting ${NODE_NAME}..."
	    sudo su - iibuser -c "mqsistart $NODE_NAME"
		
		iib_config_security.sh
		
		sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e $INTGSRV"
		sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e $OUTBOUND"

		#Restarting after applying security configuration
		echo "Re-starting ${NODE_NAME}..."		
		sudo su - iibuser -c "mqsistop $NODE_NAME"
		
		echo "Setting up the Personal certificate password of the broker key store"
		sudo su - iibuser -c "mqsisetdbparms $NODE_NAME -n brokerKeystore::password -u temp -p ${IIB_KEY_PWD}"
		echo "Setting up the Trust certificate password of the broker trust store"
		sudo su - iibuser -c "mqsisetdbparms $NODE_NAME -n brokerTruststore::password -u temp -p ${IIB_TRUST_PWD}"
		
		sudo su - iibuser -c "mqsistart $NODE_NAME"
			
	    echo "Changing webdmin port to $WEB_ADMIN_PORT"
	    sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -b webadmin -o HTTPConnector -n port -v ${WEB_ADMIN_PORT}"
	
	
	else
		echo "Starting Integration Node - ${NODE_NAME}"
	    sudo su - iibuser -c "mqsistart $NODE_NAME"
	fi
	echo "----------------------------------------"
	echo "Listing node $NODE_NAME details..."
	sudo su - iibuser -c "mqsilist"
	echo "----------------------------------------"

}

iib-license-check.sh
start
#trap stop SIGTERM SIGINT
