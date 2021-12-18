
# Based on Ubuntu 20.04 LTS
FROM ubuntu:20.04

# Some environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Toronto \
    PUID=1000 \
    PGID=1000 \
    WINDSCRIBE_USERNAME=username \
    WINDSCRIBE_PASSWORD=password \
    WINDSCRIBE_PROTOCOL=UDP \
    WINDSCRIBE_PORT=80 \
    WINDSCRIBE_LOCATION=best \
    WINDSCRIBE_LANBYPASS=on \
    WINDSCRIBE_FIREWALL=on

# Update ubuntu container, and install the basics, Add windscribe ppa, Install windscribe, and some to be removed utilities
RUN apt -y update && apt -y dist-upgrade && apt install -y gnupg apt-utils ca-certificates expect iptables iputils-ping && \
     apt-key adv --keyserver keyserver.ubuntu.com --recv-key FDC247B7 && echo 'deb https://repo.windscribe.com/ubuntu bionic main' | tee /etc/apt/sources.list.d/windscribe-repo.list && \
     echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections && \
     apt -y update && apt -y dist-upgrade && apt install -y windscribe-cli && \
     apt install -y curl net-tools iputils-tracepath && \
     apt -y autoremove && apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add in scripts for health check and start-up
ADD scripts /opt/scripts/

# Enable the health check for the VPN and app
HEALTHCHECK --interval=5m --timeout=60s \
  CMD /opt/scripts/health-check.sh || exit 1

# Run the container
CMD [ "/bin/bash", "/opt/scripts/startup.sh" ]

# Info

LABEL org.opencontainers.image.source = "https://github.com/urwrstkn8mare/docker-windscribe/tree/gateway"
