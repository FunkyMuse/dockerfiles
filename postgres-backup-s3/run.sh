#! /bin/sh

set -eo pipefail

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

chmod +x /backup.sh

if [ "${SCHEDULE}" = "**None**" ]; then
  sh backup.sh
else
  # Create crontab with proper format
  {
    echo "SHELL=/bin/sh"
    echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo "${SCHEDULE} /backup.sh"
  } > /etc/crontabs/root

  chmod 0644 /etc/crontabs/root
  exec go-crond /etc/crontabs/root
fi
