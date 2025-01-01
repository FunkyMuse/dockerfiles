FROM alpine:3.21 AS builder

RUN apk add --no-cache \
    go \
    git \
    build-base

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    export PATH="/root/go/bin:${PATH}"

RUN /root/go/bin/xcaddy build \
    --with github.com/mholt/caddy-ratelimit

FROM alpine:3.21

RUN apk add --no-cache ca-certificates

COPY --from=builder /root/go/bin/caddy /usr/bin/caddy

RUN addgroup -S caddy && \
    adduser -S caddy -G caddy

RUN mkdir /config && \
    chown -R caddy:caddy /config

USER caddy

EXPOSE 80 443

CMD ["caddy", "run"]
