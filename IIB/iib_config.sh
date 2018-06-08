#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

#sudo su - iibuser -c "source /home/iibuser/.bash_profile"

echo "--------------------------------------------------------------------"

# Copying the configuration files for the first time to required directories
echo "Copying token signing certificate : ${CERT_NAME}"
if [ ! -d /opt/ibm/iib-10.0.0.3/server/certificate ]; then
	mkdir /opt/ibm/iib-10.0.0.3/server/certificate
	chmod 775 /opt/ibm/iib-10.0.0.3/server/certificate
fi

cp /usr/local/bin/${IIB_CERTNAME} /opt/ibm/iib-10.0.0.3/server/certificate/${IIB_CERTNAME}
chmod 755 /opt/ibm/iib-10.0.0.3/server/certificate/${IIB_CERTNAME}
chown iibuser:mqbrkrs /opt/ibm/iib-10.0.0.3/server/certificate/${IIB_CERTNAME}
echo "Completed copy of token signing certificate : ${IIB_CERTNAME}"

echo "--------------------------------------------------------------------"

# Copying jar files for the first time to setup Broker.
echo "Copying the jar files to directory - /var/mqsi/config/$NODE_NAME/shared-classes/"
sudo su - iibuser -c "cp /usr/local/bin/jackson-*.jar /var/mqsi/config/$NODE_NAME/shared-classes/"
sudo su - iibuser -c "cp /usr/local/bin/jjwt-0.5.1.jar /var/mqsi/config/$NODE_NAME/shared-classes/"
sudo su - iibuser -c "cp /usr/local/bin/jplugin2.jar /var/mqsi/config/$NODE_NAME/shared-classes/"
sudo su - iibuser -c "cp /usr/local/bin/slf4j-api-*.jar /var/mqsi/config/$NODE_NAME/shared-classes/"
sudo su - iibuser -c "cp /usr/local/bin/sun.misc.BASE64Decoder.jar /var/mqsi/config/$NODE_NAME/shared-classes/"


echo "--------------------------------------------------------------------"
echo "Updating $ODBCINI for the ${DB_ESB_DSN}"
/usr/local/bin/genodbcini.sh ${DB_ESB_DSN} ${DB_CLI_DRIVER_PATH}

# Create the IIB ESB DB DSN configuration
echo "Updating DB2 CLI Driver...db2cli writecfg add -dsn ${DB_ESB_DSN} -database ${DB_ESB_NAME} -host ${DB_ESB_HOST} -port ${DB_ESB_PORT}"
db2cli writecfg add -dsn ${DB_ESB_DSN} -database ${DB_ESB_NAME} -host ${DB_ESB_HOST} -port ${DB_ESB_PORT}

echo "Validating ${DB_ESB_DSN}"
DB_TEST=`db2cli validate -dsn ${DB_ESB_DSN} -connect -user ${DB_ESB_USER} -passwd ${DB_ESB_PWD} | grep Success > /dev/null;echo $?`
if [ ${DB_TEST} -eq 0 ]; then
	echo "Connect to ${DB_ESB_DSN} test success!!!"
else
	echo "Connect to ${DB_ESB_DSN} test failed!!!"
fi

echo "Running mqsisetdbparms ${NODE_NAME} -n odbc::$DB_ESB_DSN -u ${DB_ESB_USER} -p ........"
sudo su - iibuser -c "mqsisetdbparms ${NODE_NAME} -n odbc::${DB_ESB_DSN} -u ${DB_ESB_USER} -p ${DB_ESB_PWD}"

echo "--------------------------------------------------------------------"

echo "Updating $ODBCINI for the ${DB_LOG_DSN}"
/usr/local/bin/genodbcini.sh ${DB_LOG_DSN} ${DB_CLI_DRIVER_PATH}

# Create the IIB LOG DB DSN configuration
echo "Updating DB2 CLI Driver...db2cli writecfg add -dsn ${DB_LOG_DSN} -database ${DB_LOG_NAME} -host ${DB_LOG_HOST} -port ${DB_LOG_PORT}"
db2cli writecfg add -dsn ${DB_LOG_DSN} -database ${DB_LOG_NAME} -host ${DB_LOG_HOST} -port ${DB_LOG_PORT}

echo "Validating ${DB_LOG_DSN}"
DB_TEST1=`db2cli validate -dsn ${DB_LOG_DSN} -connect -user ${DB_LOG_USER} -passwd ${DB_LOG_PWD} | grep Success > /dev/null;echo $?`
if [ ${DB_TEST1} -eq 0 ]; then
	echo "Connect to ${DB_LOG_DSN} test success!!!"
else
	echo "Connect to ${DB_LOG_DSN} test failed!!!"
fi


echo "Running mqsisetdbparms ${NODE_NAME} -n odbc::$DB_LOG_DSN -u ${DB_LOG_USER} -p ........"
sudo su - iibuser -c "mqsisetdbparms ${NODE_NAME} -n odbc::${DB_LOG_DSN} -u ${DB_LOG_USER} -p ${DB_LOG_PWD}"

echo "--------------------------------------------------------------------"

echo "Updating $ODBCINI for the ${DB_DNS_NAME}"
/usr/local/bin/genodbcini.sh ${DB_DNS_NAME} ${DB_CLI_DRIVER_PATH}

# Create the IIB LOG DB DSN configuration
echo "Updating DB2 CLI Driver...db2cli writecfg add -dsn ${DB_DNS_NAME} -database ${DB_NAME} -host ${DB_HOST} -port ${DB_PORT}"
db2cli writecfg add -dsn ${DB_DNS_NAME} -database ${DB_NAME} -host ${DB_HOST} -port ${DB_PORT}

echo "Validating ${DB_DNS_NAME}"
DB_TEST2=`db2cli validate -dsn ${DB_DNS_NAME} -connect -user ${DB_USER} -passwd ${DB_PASSWD} | grep Success > /dev/null;echo $?`
if [ ${DB_TEST2} -eq 0 ]; then
	echo "Connect to ${DB_DNS_NAME} test success!!!"
else
	echo "Connect to ${DB_DNS_NAME} test failed!!!"
fi

echo "Running mqsisetdbparms ${NODE_NAME} -n odbc::${DB_DNS_NAME} -u ${DB_USER} -p ......."
sudo su - iibuser -c "mqsisetdbparms ${NODE_NAME} -n odbc::${DB_DNS_NAME} -u ${DB_USER} -p ${DB_PASSWD}"

echo "--------------------------------------------------------------------"