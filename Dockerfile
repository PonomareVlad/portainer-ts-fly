# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM portainer/portainer-ce:alpine
RUN apk update && apk add ca-certificates iptables iptables-legacy ip6tables && rm -rf /var/cache/apk/* && ln -s /sbin/iptables-legacy /sbin/iptables && ln -s /sbin/ip6tables-legacy /sbin/ip6tables

# Copy binary to production image.
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale /data/tailscale

# Run on container startup.
ENTRYPOINT ["/app/start.sh"]
