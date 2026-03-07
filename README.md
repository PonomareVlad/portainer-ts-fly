# portainer-ts-fly

Portainer CE with Tailscale on Fly.io — private, secure container management accessible only via your Tailnet.

## Overview

This deploys [Portainer CE](https://www.portainer.io/) on [Fly.io](https://fly.io/) with [Tailscale](https://tailscale.com/) integration for private network access. No public IP or `*.fly.app` domain is exposed.

## Architecture

- **Portainer** binds to `127.0.0.1:9000` (HTTP) and `127.0.0.1:9443` (HTTPS) — localhost only, no public access
- **Tailscale** exposes Portainer via `tailscale serve` (443 → 9000) for private TLS access
- **`[[services]]` UDP 41641** — enables direct WireGuard connections if a dedicated IPv4 is allocated; UDP services do not auto-allocate a public IP
- **No health checks** — Fly.io checks require `0.0.0.0` binding which would expose Portainer publicly
- Persistent data stored on a Fly.io volume mounted at `/data`

## Configuration

### fly.toml

| Setting | Value | Reason |
|---|---|---|
| `primary_region` | `fra` | Deploy region (Frankfurt) |
| `kill_timeout` | `10` | Extra time for Tailscale + Portainer graceful shutdown |
| `[[services]]` | UDP 41641 | Tailscale WireGuard port; UDP does not auto-allocate a public IP |
| `[[restart]] policy` | `"always"` | Automatically restart on unexpected exit (unlimited retries) |
| `[[vm]]` | `shared-cpu-1x` | Explicit machine sizing (256 MB) |

### Secrets

Set the following secrets before deploying:

```sh
fly secrets set TAILSCALE_AUTHKEY=tskey-auth-...
```

## Deploy

```sh
fly deploy
```