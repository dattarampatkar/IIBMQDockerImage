#!/bin/bash
# -*- mode: sh -*-
# © Copyright IBM Corporation 2015, 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source /opt/mqm/bin/setmqenv -s
echo "----------------------------------------"
dspmqver
echo "----------------------------------------"

cd /usr/local/bin/
. ./setenv.sh

. /opt/ibm/iib-10.0.0.3/server/bin/mqsiprofile
/opt/ibm/iib-10.0.0.3/server/sample/wmq/iib_createqueues.sh ${MQ_QMGR_NAME} mqbrkrs

setmqaut -m ${MQ_QMGR_NAME} -t q -n SYSTEM.MQEXPLORER.REPLY.MODEL -g mqusers +inq +get +dsp

setmqaut -m ${MQ_QMGR_NAME}  -t q -n SYSTEM.MQEXPLORER.REPLY.MODEL -p iibuser +all

setmqaut -m ${MQ_QMGR_NAME} -t q -n SYSTEM.BROKER.* -g mqusers +inq +dsp

setmqaut -m ${MQ_QMGR_NAME} -t q -n MYWIZARD.POC.* -g mqusers +inq +get +put +dsp

setmqaut -m ${MQ_QMGR_NAME} -t q -n PAPL.ESB.* -g mqusers +inq +get +put +dsp

setmqaut -m ${MQ_QMGR_NAME} -t q -n MW.TEST.* -g mqusers +inq +get +put +dsp

setmqaut -m ${MQ_QMGR_NAME} -t qmgr -g mqbrkrs +all

setmqaut -m ${MQ_QMGR_NAME} -t q -n SYSTEM.BROKER.* -g mqbrkrs +all


setmqaut -m ${MQ_QMGR_NAME} -t q -n MW.TEST.* -g mqbrkrs +all

setmqaut -m ${MQ_QMGR_NAME} -t q -n MYWIZARD.POC.IN.* -g mqbrkrs +all

setmqaut -m ${MQ_QMGR_NAME} -t topic -n OutboundConnector -g mqbrkrs +all

