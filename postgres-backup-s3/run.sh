#! /bin/sh

set -eo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

check_aws_credentials() {
    if [ -n "$S3_ACCESS_KEY_ID" ] && [ -n "$S3_SECRET_ACCESS_KEY" ]; then
        export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
    fi

    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log "ERROR: S3 credentials not found or invalid"
        exit 1
    fi
}

print_config() {
    log "PostgreSQL Backup Configuration:"
    log "--------------------------------"
    log "Database Host: ${POSTGRES_HOST}"
    log "Database Port: ${POSTGRES_PORT}"
    log "Database Name: ${POSTGRES_DATABASE}"
    log "S3 Bucket: ${S3_BUCKET}"
    log "S3 Region: ${S3_REGION}"
    log "S3 Endpoint: ${S3_ENDPOINT:-'Default AWS Endpoint'}"
    log "S3v4 Signature: ${S3_S3V4}"

    if [ "${SCHEDULE}" != "**None**" ]; then
        log "Backup Schedule: ${SCHEDULE}"
    else
        log "Backup Schedule: Running once (no schedule)"
    fi
}

cleanup_old_backups() {
    if [ "${DELETE_OLDER_THAN}" = "**None**" ]; then
        return
    fi

    log "Cleanup: Files older than ${DELETE_OLDER_THAN}"
    log "Scanning backups in s3://${S3_BUCKET}/${S3_PREFIX}/"

    local found_files=0
    while IFS= read -r line; do
        local created
        created=$(echo "$line" | awk '{print $1" "$2}')
        created=$(date -d "$created" +%s)
        local older_than
        older_than=$(date -d "$DELETE_OLDER_THAN" +%s)

        if [ "$created" -lt "$older_than" ]; then
            local file_name
            file_name=$(echo "$line" | awk '{print $4}')
            if [ -n "$file_name" ] && [[ $file_name =~ .*_[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z\.sql\.gz$ ]]; then
                local file_size
                file_size=$(echo "$line" | awk '{print $3}')
                local created_date
                created_date=$(echo "$line" | awk '{print $1" "$2}')
                printf 'File: %s\nSize: %s\nCreated: %s\n\n' "$file_name" "$file_size" "$created_date"
                found_files=1
            fi
        fi
    done < <(aws $AWS_ARGS s3 ls "s3://${S3_BUCKET}/${S3_PREFIX}/" | grep -v " PRE ")

    if [ "$found_files" -eq 0 ]; then
        log "No files found matching age criteria"
    fi
}

configure_s3() {
    if [ "${S3_S3V4}" = "yes" ]; then
        aws configure set default.s3.signature_version s3v4
    fi
}

main() {
    check_aws_credentials
    print_config
    configure_s3
    cleanup_old_backups

    if [ "${SCHEDULE}" = "**None**" ]; then
        sh backup.sh
    else
        echo -e "SHELL=/bin/sh\n${SCHEDULE} /bin/sh /backup.sh" > /etc/crontabs/root
        exec go-crond /etc/crontabs/root
    fi
}

main "$@"
