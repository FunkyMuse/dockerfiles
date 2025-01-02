FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    curl \
    docker.io \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY monitor-containers.sh .

RUN chmod +x monitor-containers.sh

CMD ["./monitor-containers.sh"]
