#!/bin/sh

modprobe xt_mark

echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

/app/tailscaled --state=/data/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock --port 41641 &
/app/tailscale up --auth-key=${TAILSCALE_AUTHKEY} --hostname=portainer --advertise-exit-node --ssh
/app/tailscale serve --bg 9000

exec /portainer --http-enabled --bind "127.0.0.1:9000" --bind-https ""
