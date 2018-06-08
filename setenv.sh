#!/bin/bash

. gen_instance_number.sh

#set required environment
export LICENSE=accept
export MQ_QMGR_NAME=MYWIZARD.QM.POC.${INSTANCE_NUMBER}
export NODE_NAME=MYWIZARDPOC.${INSTANCE_NUMBER}
export INTGSRV=MWINTGSRV
export OUTBOUND=OUTBOUND
export WEB_ADMIN_PORT=9080
export MQ_CONNECT_USER=iibpoc01
export MQ_CONNECT_PASSWD=passw0rd

# Following are the ESB DB DSN variables
export DB_ESB_DSN=5092_ESB_DB
export DB_ESB_HOST=dashdb-entry-yp-dal09-07.services.dal.bluemix.net
export DB_ESB_PORT=50000
export DB_ESB_NAME=BLUDB
export DB_ESB_USER=dash6394
export DB_ESB_PWD=pu7rSkKEiWpf

# Following are the LOG DB DSN variables
export DB_LOG_DSN=5092_ESB_LOG
export DB_LOG_HOST=dashdb-entry-yp-dal09-07.services.dal.bluemix.net
export DB_LOG_PORT=50000
export DB_LOG_NAME=BLUDB
export DB_LOG_USER=dash6394
export DB_LOG_PWD=pu7rSkKEiWpf

# General IIB  and security related variable
export IIB_HOME=/opt/ibm/iib-10.0.0.3
export IIB_HTTP_PORT=7800
export IIB_KEYSTORE=/opt/ibm/iib-10.0.0.3/truststore.jks
export IIB_TRUSTSTORE=/opt/ibm/iib-10.0.0.3/truststore.jks
export IIB_KEY_PWD=bluemix
export IIB_TRUST_PWD=bluemix
export IIB_CERTNAME=tokensigning.accenture.com.cer

#db2 cli driver setup env variables
export DB2_CLI_DRIVER_INSTALL_PATH=/opt/db2cli/odbc_cli/clidriver
export PATH=$PATH:$DB2_CLI_DRIVER_INSTALL_PATH/bin:$DB2_CLI_DRIVER_INSTALL_PATH/adm
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DB2_CLI_DRIVER_INSTALL_PATH/lib
export DB_CLI_DRIVER_PATH=$DB2_CLI_DRIVER_INSTALL_PATH/lib/libdb2o.so #use for generating odbc.ini

export ODBCINI=/opt/ibm/iib-10.0.0.3/server/ODBC/unixodbc/odbc.ini

# All DB environment variables
export DB_DNS_NAME=MYDB2DB
export DB_NAME=BLUDB 
export DB_HOST=dashdb-entry-yp-dal09-07.services.dal.bluemix.net 
export DB_PORT=50000
export DB_USER=dash6394 
export DB_PASSWD=pu7rSkKEiWpf
