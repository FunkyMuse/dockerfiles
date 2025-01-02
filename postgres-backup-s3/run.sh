#! /bin/sh

set -eo pipefail

# Print non-sensitive configuration information
echo "PostgreSQL Backup Configuration:"
echo "--------------------------------"
echo "Database Host: ${POSTGRES_HOST}"
echo "Database Port: ${POSTGRES_PORT}"
echo "Database Name: ${POSTGRES_DATABASE}"
echo "S3 Bucket: ${S3_BUCKET}"
echo "S3 Region: ${S3_REGION}"
echo "S3 Endpoint: ${S3_ENDPOINT:-'Default AWS Endpoint'}"
echo "S3v4 Signature: ${S3_S3V4}"
if [ "${SCHEDULE}" != "**None**" ]; then
    echo "Backup Schedule: ${SCHEDULE}"
else
    echo "Backup Schedule: Running once (no schedule)"
fi
if [ "${DELETE_OLDER_THAN}" != "**None**" ]; then
    echo "Cleanup: Files older than ${DELETE_OLDER_THAN}"
    echo "\nScanning backups in s3://$S3_BUCKET/$S3_PREFIX/"
    echo "Checking for files older than ${DELETE_OLDER_THAN}:"
    echo "-------------------------------------"
    FOUND_FILES=0
    aws $AWS_ARGS s3 ls s3://$S3_BUCKET/$S3_PREFIX/ | grep " PRE " -v | while read -r line;
    do
        created=`echo $line|awk {'print $1" "$2'}`
        created=`date -d "$created" +%s`
        older_than=`date -d "$DELETE_OLDER_THAN" +%s`
        if [ $created -lt $older_than ]
            then
            fileName=`echo $line|awk {'print $4'}`
            if [ $fileName != "" ] && [[ $fileName =~ .*_[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z\.sql\.gz$ ]]
                then
                fileSize=`echo $line|awk {'print $3'}`
                created_date=`echo $line|awk {'print $1" "$2'}`
                printf 'File: %s\nSize: %s\nCreated: %s\n\n' "$fileName" "$fileSize" "$created_date"
                FOUND_FILES=1
            fi
        fi
    done;
    if [ $FOUND_FILES -eq 0 ]; then
        echo "No files found matching age criteria"
    fi
    echo "-------------------------------------"
fi
echo "--------------------------------"

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

if [ "${SCHEDULE}" = "**None**" ]; then
  sh backup.sh
else
  echo -e "SHELL=/bin/sh\n${SCHEDULE} /bin/sh /backup.sh" > /etc/crontabs/root
  exec go-crond /etc/crontabs/root
fi
