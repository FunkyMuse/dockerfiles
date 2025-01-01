# Caddy with Rate Limit Plugin Docker Image

This Docker image extends the official Caddy image with the rate limiting module from [github.com/mholt/caddy-ratelimit](https://github.com/mholt/caddy-ratelimit). It provides both internal and distributed HTTP rate limiting capabilities.

## Features

- Multiple rate limit zones (static or dynamic)
- Sliding window algorithm
- Distributed rate limiting across clusters
- Automatic Retry-After header management
- Optional jitter for retry times
- Memory-efficient implementation
- Configurable through Caddyfile

## Usage

### Pull the Image

```bash
docker pull ghcr.io/FunkyMuse/dockerfiles/caddy-rate-limit:latest
```

### Example Configurations

Here are some common use cases:

1. **Basic Rate Limiting**

```caddyfile
:80 {
    rate_limit {
        zone global {
            key    static
            events 100
            window 1m
        }
    }
}
```

2. **IP-based Rate Limiting**

```caddyfile
:80 {
    rate_limit {
        zone per_ip {
            key    {remote_host}
            events 10
            window 5s
        }
    }
}
```

3. **Multiple Zones with Different Rules**

```caddyfile
:80 {
    rate_limit {
        zone api {
            match {
                path /api/*
            }
            key    {remote_host}
            events 100
            window 1m
        }
        zone auth {
            match {
                path /auth/*
            }
            key    {remote_host}
            events 5
            window 5m
        }
    }
}
```

4. **Distributed Rate Limiting**

```caddyfile
:80 {
    rate_limit {
        distributed
        zone shared {
            key    {remote_host}
            events 1000
            window 1h
        }
        storage redis {
            host redis:6379
        }
    }
}
```

## Environment Variables

No special environment variables are required. Use standard Caddy environment variables as needed.

## Building from Source

If you want to build the image yourself:

```bash
git clone <this-repository>
cd caddy-rate-limit
docker build -t caddy-rate-limit .
```

## Notes

- The rate limit module is still under development and may have bugs
- For production use, carefully tune your rate limit settings
- When using distributed rate limiting, all instances must share the same configuration
- Consider adding jitter to prevent thundering herd problems in high-traffic scenarios

## License

This Docker image inherits licenses from:
- Caddy: Apache License 2.0
- caddy-ratelimit module: MIT License

## Acknowledgments

This image bundles the excellent rate limit module created by Matt Holt (@mholt). Visit the [original repository](https://github.com/mholt/caddy-ratelimit) for more detailed documentation and updates.
