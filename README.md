# portainer-ts-fly

Portainer CE with Tailscale on Fly.io — private, secure container management accessible only via your Tailnet.

## Overview

This deploys [Portainer CE](https://www.portainer.io/) on [Fly.io](https://fly.io/) with [Tailscale](https://tailscale.com/) integration for private network access. No public IP or `*.fly.app` domain is exposed.

## Architecture

- **Portainer** binds to `127.0.0.1:9000` (HTTP) and `127.0.0.1:9443` (HTTPS)
- **Tailscale** exposes Portainer via `tailscale serve` (443 → 9000) for private TLS access
- **UDP port 41641** is exposed for Tailscale WireGuard / DERP relay traffic
- Persistent data stored on a Fly.io volume mounted at `/data`

## Configuration

### fly.toml

| Setting | Value | Reason |
|---|---|---|
| `primary_region` | `fra` | Deploy region (Frankfurt) |
| `kill_timeout` | `10` | Extra time for Tailscale + Portainer graceful shutdown |
| `auto_stop_machines` | `"off"` | Always-on service, must not be stopped automatically |
| `auto_start_machines` | `false` | No Fly Proxy auto-start needed (private access via Tailscale) |
| `[[restart]] policy` | `"always"` | Automatically restart on unexpected exit |
| `[[vm]]` | `shared-cpu-1x` / `1gb` | Explicit machine sizing for predictable behavior |

### Secrets

Set the following secrets before deploying:

```sh
fly secrets set TAILSCALE_AUTHKEY=tskey-auth-...
```

## Deploy

```sh
fly deploy
```