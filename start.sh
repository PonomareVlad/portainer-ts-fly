#!/bin/sh

modprobe xt_mark

echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

/app/tailscaled --state=/data/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock --port 41641 &
/app/tailscale up --auth-key=${TAILSCALE_AUTHKEY} --hostname=portainer --advertise-exit-node --ssh
/app/tailscale serve --bg https+insecure://localhost:9443

exec /portainer --http-disabled --bind-https "127.0.0.1:9443" --tunnel-addr "127.0.0.1"
