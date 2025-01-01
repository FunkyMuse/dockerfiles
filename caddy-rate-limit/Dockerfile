FROM alpine:3.21 AS builder

RUN apk add --no-cache \
    go \
    git \
    build-base

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    /root/go/bin/xcaddy build \
    --with github.com/mholt/caddy-ratelimit

FROM alpine:3.21

RUN apk add --no-cache ca-certificates

COPY --from=builder /caddy /usr/bin/caddy

CMD ["caddy", "run"]
