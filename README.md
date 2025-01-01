# Docker Image Collection

Collection of lightweight and ready-to-use docker images based on the work done by [schickling](https://github.com/schickling/dockerfiles).

## Images

* **[postgres-backup-s3](/postgres-backup-s3)** - Backup PostgresSQL to S3 (supports periodic backups)
* **[postgres-restore-s3](/postgres-restore-s3)** - Restore PostgresSQL from S3
* **[caddy-rate-limit](/caddy-rate-limit)** - Caddy with rate limit

## Contributing

Contributions are always welcome! Feel free to:
- Submit bug reports or feature requests through issues
- Propose new Docker images
- Improve existing images or documentation
- Fix typos or clarify explanations

Please make sure to test your changes before submitting a pull request.

## FAQ

### Why do you use `install.sh` scripts instead of putting the commands in the `Dockerfile`?

Structuring an image this way keeps it much smaller.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
