#! /bin/sh

set -eo pipefail

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

chmod +x /backup.sh

if [ "${SCHEDULE}" = "**None**" ]; then
  sh backup.sh
else
  # Create crontab with proper format and permissions
  echo "SHELL=/bin/sh
${SCHEDULE} backup.sh" > /etc/crontabs/root

  # Ensure proper permissions on crontab
  chmod 0644 /etc/crontabs/root

  exec go-crond /etc/crontabs/root
fi
