#!/bin/bash
# Call this script with at UsecaseName, StartDateTime & EndDateTime

UsecaseName=$1
RequestString="Message Received from POST"
ExceptionString1="UserException:Details : RS_SF : TARGET WEBSERVICE ERROR"
ExceptionString2="UserException:Details : E2EID SF: EXCEPTION RECEIVED FROM WEBSERVICE"
SocketString="UserException:Details : SocketException"
SuccessString="RS_SF:TARGET RESPONSE SUCCESS"
LastResponse="RS_SF"

TOTAL_REQUEST=$(cat /tmp/${UsecaseName}.log | grep "$RequestString" |  wc -l)
ERROR_RESPONSE1=$(cat /tmp/${UsecaseName}.log | grep "$ExceptionString1" |  wc -l)
ERROR_RESPONSE2=$(cat /tmp/${UsecaseName}.log | grep "$ExceptionString2" |  wc -l)
TOTAL_SUCCESS_RESPONSE=$(cat /tmp/${UsecaseName}.log | grep "$SuccessString" |  wc -l)
TOTAL_SOCKET_RESPONSE=$(cat /tmp/${UsecaseName}.log | grep "$SocketString" |  wc -l)
TOTAL_ERROR_RESPONSE=$((ERROR_RESPONSE1 + ERROR_RESPONSE2))

echo $(echo "Total Requests 		: ") $TOTAL_REQUEST
echo $(echo "Total Success Response : ") $TOTAL_SUCCESS_RESPONSE
echo $(echo "Total Error Response 	: ") $TOTAL_ERROR_RESPONSE
echo $(echo "Total Socket Response 	: ") $TOTAL_SOCKET_RESPONSE

FIRST_RESPONSE=$(grep -m 1 "$RequestString" /tmp/${UsecaseName}.log | cut -c 1-15)
LAST_RESPONSE=$(grep "$LastResponse" /tmp/${UsecaseName}.log | tail -1 | cut -c 1-15)

STARTTIME=$(date -u -d "$FIRST_RESPONSE" +"%s")
ENDTIME=$(date -u -d "$LAST_RESPONSE" +"%s")
echo $(echo "Total Time Taken : ") $(date -u -d "0 $ENDTIME sec - $STARTTIME sec" +"%H:%M:%S")
echo
