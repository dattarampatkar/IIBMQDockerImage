#!/bin/bash 

set -e

L_FILE="/tmp/clientConfig.log"

echo "-----------------------------------------------------------------------------------"
echo "  Configuring ${S_NAME} under ${U_NAME}@${G_NAME}..."
echo "-----------------------------------------------------------------------------------"
#: ${SYSLOG_SERVER_IP?"ERROR: You need to set the SYSLOG_SERVER_IP environment variable"}
#: ${SYSLOG_SERVER_PORT?"ERROR: You need to set the SYSLOG_SERVER_PORT environment variable"}

date > $L_FILE
echo "##############################" >> $L_FILE
echo $SYSLOG_SERVER_IP >> $L_FILE
echo $SYSLOG_SERVER_PORT >> $L_FILE

echo "##############################" >> $L_FILE
cat /etc/syslog-ng/conf.d/client.conf >> $L_FILE
echo "##############################" >> $L_FILE
cat /etc/syslog-ng/syslog-ng.conf >> $L_FILE
echo "##############################" >> $L_FILE
cat /etc/default/syslog-ng >> $L_FILE
echo "##############################" >> $L_FILE

# Replace the system() source because inside Docker we can't access /proc/kmsg.
# https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
sed -i -E "s/^(\s*)system\(\);/\1unix-stream(\"\/dev\/log\");/" /etc/syslog-ng/syslog-ng.conf
# Uncomment 'SYSLOGNG_OPTS="--no-caps"' to avoid the following warning:
# syslog-ng: Error setting capabilities, capability management disabled; error='Operation not permitted'
# http://serverfault.com/questions/524518/error-setting-capabilities-capability-management-disabled#
sed -i "s/^#\(SYSLOGNG_OPTS=\"--no-caps\"\)/\1/g" /etc/default/syslog-ng
#syslog-ng update log level to 0
sed -i "s/^#\(CONSOLE_LOG_LEVEL=\)1/\10/g" /etc/default/syslog-ng

sudo sed -e "s/\^SYSLOG_SERVER_IP\^/$SYSLOG_SERVER_IP/g" -i /etc/syslog-ng/conf.d/client.conf
sudo sed -e "s/\^SYSLOG_SERVER_PORT\^/$SYSLOG_SERVER_PORT/g" -i /etc/syslog-ng/conf.d/client.conf

echo "##############################" >> $L_FILE
cat /etc/syslog-ng/conf.d/client.conf >> $L_FILE
echo "##############################" >> $L_FILE
cat /etc/syslog-ng/syslog-ng.conf >> $L_FILE
echo "##############################" >> $L_FILE
cat /etc/default/syslog-ng >> $L_FILE
echo "##############################" >> $L_FILE

cat $L_FILE

stop(){
	echo "stop on clientConfig.sh called..."
}

trap stop SIGTERM SIGKILL

