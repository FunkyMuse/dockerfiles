Collection of lightweight and ready-to-use docker images based on the work done by [schickling](https://github.com/schickling/dockerfiles)


## Images

* **[postgres-backup-s3](/postgres-backup-s3)** - Backup PostgresSQL to S3 (supports periodic backups)
* **[postgres-restore-s3](/postgres-restore-s3)** - Restore PostgresSQL from S3

## FAQ

##### Why do you use `install.sh` scripts instead of putting the commands in the `Dockerfile`?

Structuring an image this way keeps it much smaller.
