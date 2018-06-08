#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

#sudo su - iibuser -c "source /home/iibuser/.bash_profile"
echo "--------------------------------------------------------------------"

cp /usr/local/bin/truststore.jks /opt/ibm/iib-10.0.0.3/
chmod 755 /opt/ibm/iib-10.0.0.3/truststore.jks
chown iibuser:mqbrkrs /opt/ibm/iib-10.0.0.3/truststore.jks
echo "Completed copy of the jks file : truststore.jks"

echo "--------------------------------------------------------------------"

echo "Provision the key store and trust store for the HTTPs connections"
#sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -b httplistener -o HTTPListener -n enableSSLConnector -v true"
#sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -b httplistener -o HTTPSConnector -n keystoreFile -v $IIB_KEYSTORE"
sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -o BrokerRegistry -n brokerKeystoreFile -v $IIB_KEYSTORE"
#sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -b httplistener -o HTTPSConnector -n keystorePass -v $IIB_KEY_PWD"
sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -b httplistener -o HTTPConnector -n port -v $IIB_HTTP_PORT"

sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -o BrokerRegistry -n brokerTruststoreFile -v $IIB_TRUSTSTORE"
sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -o ComIbmJVMManager -n truststoreFile -v $IIB_TRUSTSTORE"

echo "--------------------------------------------------------------------"

