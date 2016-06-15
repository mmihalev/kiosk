#!/bin/bash
exec 1> >(logger -s -t $(basename $0)) 2>&1

FILE=$1
TRANSFER=$2

SAVE_DIR=/home/kiosk/html/
REMOTE_HOST=http://212.50.20.44
REMOTE_REPORT_PATH=/auth/transfers/report
REMOTE_MD5_PATH=/auth/transfers/md5sum

printf "Transfer #${TRANSFER}: Started\n"

wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 2 ${REMOTE_HOST}/files/htmls/${FILE} -O ${SAVE_DIR}${FILE} &> /dev/null

printf "Transfer #${TRANSFER}: Downloading ${REMOTE_HOST}/files/htmls/${FILE} in ${SAVE_DIR}${FILE}\n"

if [[ "$?" != 0 ]]; then
    STATUS="Error downloading file ${REMOTE_HOST}/files/htmls/${FILE}"
    txt="hostname=${HOSTNAME}&transfer=${TRANSFER}&status=${STATUS}"
    response=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -d "$txt" ${REMOTE_HOST}${REMOTE_REPORT_PATH})

    printf "Transfer #${TRANSFER}: Failed. ${STATUS}\n"
else
    printf "Transfer #${TRANSFER}: Download succeeded\n"

    # Check file md5sum
    remote_md5sum=$(curl -L --silent ${REMOTE_HOST}${REMOTE_MD5_PATH}?file=${FILE})
    local_md5sum=($(md5sum ${SAVE_DIR}${FILE}))

    if [[ "$remote_md5sum" == "$local_md5sum" ]]; then
        printf "Transfer #${TRANSFER}: Checksums matched\n"

        rm -rf ${SAVE_DIR}
        unzip -q -o ${SAVE_DIR}${FILE} -d ${SAVE_DIR}

        if [[ $? == 0 ]] ; then
            printf "Transfer #${TRANSFER}: Unzip succeeded\n"

            printf "Transfer #${TRANSFER}: Notifying ${REMOTE_HOST}${REMOTE_REPORT_PATH}\n"

            STATUS="success"
            txt="hostname=${HOSTNAME}&transfer=${TRANSFER}&status=${STATUS}"
            response=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -d "$txt" ${REMOTE_HOST}${REMOTE_REPORT_PATH})

            printf "Transfer #${TRANSFER}: Notification succeeded (response code: ${response})\n"
            printf "Transfer #${TRANSFER}: Completed\n"
            printf "Rebooting after 5 seconds...\n"

            sleep 5
            #sudo /sbin/reboot

        else
            STATUS="Unzip failed. Can't unzip from ${SAVE_DIR}${FILE} to ${SAVE_DIR}"
            txt="hostname=${HOSTNAME}&transfer=${TRANSFER}&status=${STATUS}"
            response=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -d "$txt" ${REMOTE_HOST}${REMOTE_REPORT_PATH})

            printf "Transfer #${TRANSFER}: ${STATUS}\n"
        fi ;

    else
        STATUS="File downloaded but md5sum's are different"
        txt="hostname=${HOSTNAME}&transfer=${TRANSFER}&status=${STATUS}"
        response=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -d "$txt" ${REMOTE_HOST}${REMOTE_REPORT_PATH})

        printf "Transfer #${TRANSFER}: Failed. ${STATUS}\n"
    fi
fi