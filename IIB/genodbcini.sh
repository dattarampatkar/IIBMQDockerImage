#!/bin/bash

set -e 

#self testing content commented.
#export DB_ALIAS_NAME=MYDB21
#export DB_CLI_DRIVER_PATH=/opt/db2cli/clidriver/lib/libdb2o.so
#sed -e "s|\^DB_ALIAS_FOR_BROKER\^|$DB_ALIAS_NAME|" odbc.template | sed -e "s|\^DB_CLI_DRIVER_PATH\^|$DB_CLI_DRIVER_PATH|" > odbc.tmp

#Command to generate odbc.tmp using parameters.
# ${1} is DB Alias name entry you want in broker odbc.ini file
# ${2} is CLI Driver path for DB2, refer example on above line.
# Assumption:
#		1. always run with persmision of iib admin
#		2. ODBCINI env variable defined with correct path of broker odbc.ini
#		3. user running this script has full access to /tmp
#		4. odbc.template file with suitable content is available in /usr/local/bin

sed -e "s|\^DB_ALIAS_FOR_BROKER\^|$1|" /usr/local/bin/odbc.template | sed -e "s|\^DB_CLI_DRIVER_PATH\^|$2|" > /tmp/odbc.tmp
cp $ODBCINI /tmp/odbc.ini.ORG
cat $ODBCINI /tmp/odbc.tmp > /tmp/newodbc.ini
cp /tmp/newodbc.ini $ODBCINI
chown mqm:mqbrkrs $ODBCINI
chmod 664 $ODBCINI