# Docker Container Monitor

A Docker container monitoring solution that sends real-time notifications to Telegram when containers start or die.

## Features

- Real-time container monitoring
- Telegram notifications for container events
- Exit code reporting for failed containers
- Automatic restart capability
- Secure environment variable handling

## Prerequisites

- Docker and Docker Compose
- Telegram Bot Token (from [@BotFather](https://t.me/botfather))
- Telegram Chat ID (from [@userinfobot](https://t.me/userinfobot))

## Configuration

### Environment Variables

| Variable   | Description                | Example                    |
|-----------|----------------------------|----------------------------|
| TGM_BOT_TOKEN | Telegram bot token         | 123456789:ABCdefGHIjklMNO |
| TGM_CHAT_ID   | Telegram chat ID          | -123456789                |
| USERNAME  | Telegram username          | @username                 |

## Monitoring Output

The monitor sends notifications in the following format:

- Start: `Container started: container_name`
- Death: `Container died: container_name (exit_code) @username`

## Troubleshooting

1. No notifications:
    - Verify TGM_BOT_TOKEN and TGM_CHAT_ID
    - Check container logs: `docker-compose logs -f`

2. Permission errors:
    - Check Docker socket permissions
    - Verify script permissions
    - Validate environment variables

## License

MIT License

## Support

For support, please open an issue with:
- Problem description
- Relevant logs
- Steps to reproduce
