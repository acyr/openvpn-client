FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
LABEL maintainer="acyr"

# Install openvpn
RUN \
    if [ -z ${OPENVPN_RELEASE+x} ]; then \
      OPENVPN_RELEASE=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
      && awk '/^P:openvpn$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
    fi && \
    apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl ip6tables iptables shadow-login openvpn \
                shadow tini tzdata && \
    addgroup -S vpn && \
    printf "OpenVPN version: ${OPENVPN_RELEASE}" > /build_version && \
    echo "**** clean up ****" && \
    rm -rf /tmp/*

COPY openvpn.sh /usr/bin/

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -LSs 'https://api.ipify.org'

VOLUME ["/vpn"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/openvpn.sh"]
