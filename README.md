# portainer-ts-fly

Portainer CE with Tailscale on Fly.io — private, secure container management accessible only via your Tailnet.

## Overview

This deploys [Portainer CE](https://www.portainer.io/) on [Fly.io](https://fly.io/) with [Tailscale](https://tailscale.com/) integration for private network access. No public IP or `*.fly.app` domain is exposed.

## Architecture

- **Portainer** binds to `0.0.0.0:9000` (HTTP) and `127.0.0.1:9443` (HTTPS)
- **Tailscale** exposes Portainer via `tailscale serve` (443 → 9000) for private TLS access
- **No `[[services]]` section** — prevents Fly.io from allocating a public IP; Tailscale connects via DERP relays
- **Health check** on `/api/status` via port 9000 — safe without `[[services]]` (no public IP)
- Persistent data stored on a Fly.io volume mounted at `/data`

## Configuration

### fly.toml

| Setting | Value | Reason |
|---|---|---|
| `primary_region` | `fra` | Deploy region (Frankfurt) |
| `kill_timeout` | `10` | Extra time for Tailscale + Portainer graceful shutdown |
| `[[restart]] policy` | `"always"` | Automatically restart on unexpected exit (unlimited retries) |
| `[checks.portainer]` | HTTP `/api/status` on port 9000 | Monitors Portainer health (port not publicly exposed) |
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