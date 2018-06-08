#!/bin/bash

#set required environment
. setenv.sh 

#configure and start syslog-ng
#syslog-ng.sh &

# Execute mq setup script
mq.sh

# Execute db2 setup script
#db2.sh

# Execute iib setup script
iib_manage.sh &

stop()
{
   echo "Do nothing...SIGTERM or SIGINT received..."
}

trap stop SIGTERM SIGINT

while true; do
    sleep 60
done

wait
echo "Scripts executed successfully!"
