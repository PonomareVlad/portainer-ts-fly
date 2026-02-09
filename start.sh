#!/bin/sh

sudo modprobe xt_mark

echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sudo /app/tailscaled --state=/data/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock --port 41641 &
sudo /app/tailscale up --auth-key=${TAILSCALE_AUTHKEY} --hostname=portainer --advertise-exit-node --ssh
sudo /app/tailscale serve --bg 9000

sudo exec /portainer --http-enabled --bind "127.0.0.1:9000" --bind-https "127.0.0.1:9443"
