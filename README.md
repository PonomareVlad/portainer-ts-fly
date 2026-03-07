# portainer-ts-fly

Run [Portainer CE](https://www.portainer.io/) on [Fly.io](https://fly.io/) with private access through [Tailscale](https://tailscale.com/).

Portainer binds to localhost only and is exposed exclusively via Tailscale, so there is no public endpoint — all access is gated through your Tailnet.

## Prerequisites

- [Fly CLI](https://fly.io/docs/flyctl/install/) (`flyctl`)
- A [Fly.io](https://fly.io/) account
- A [Tailscale](https://tailscale.com/) account and an [auth key](https://tailscale.com/kb/1085/auth-keys)

## Setup

1. **Create the Fly app and storage volume:**

   ```sh
   fly apps create portainer-ts-fly
   fly volumes create portainer_data --region fra --size 1
   ```

2. **Set the Tailscale auth key as a secret:**

   ```sh
   fly secrets set TAILSCALE_AUTHKEY=tskey-auth-...
   ```

3. **Deploy:**

   ```sh
   fly deploy
   ```

Once deployed, the Portainer UI will be available on your Tailnet at `https://portainer`.

## How it works

```
Internet ──✕──▶ Fly VM (no public IP)
                  ├── tailscaled (port 41641)
                  │     └── tailscale serve → 127.0.0.1:9000
                  └── portainer (127.0.0.1:9000 / :9443)
                        └── persistent data → /data

Tailnet ──────▶ Fly VM ──▶ Portainer UI
```

- **Portainer** binds to `127.0.0.1` on ports 9000 (HTTP) and 9443 (HTTPS) — not reachable from the internet.
- **Tailscale** connects the VM to your Tailnet, runs `tailscale serve` to proxy port 9000, and advertises the node as an exit node with SSH enabled.
- **Fly.io** provides a shared-cpu-1x VM in `fra` with a persistent volume mounted at `/data` for Portainer and Tailscale state.

## Configuration

| Variable | Description |
|---|---|
| `TAILSCALE_AUTHKEY` | Tailscale auth key used to join your Tailnet (set via `fly secrets set`) |

Key settings in `fly.toml`:

| Setting | Value | Notes |
|---|---|---|
| `primary_region` | `fra` | Change to a [region](https://fly.io/docs/reference/regions/) closer to you |
| `vm.size` | `shared-cpu-1x` | Smallest Fly VM tier |
| `mounts.source` | `portainer_data` | Name of the persistent volume |

## Security

- No public IP is allocated — the `fly.toml` has no `[[services]]` section.
- Portainer listens on localhost only; it cannot be reached without Tailscale.
- Tailscale state is persisted to the mounted volume so the node identity survives restarts.
- IPv4/IPv6 forwarding and NAT masquerading are enabled for exit-node functionality.
