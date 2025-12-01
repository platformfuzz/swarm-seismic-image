ARG JAVA_BASE_IMAGE=eclipse-temurin:8-jre
ARG SWARM_VERSION=3.5.0

FROM ${JAVA_BASE_IMAGE}

ARG SWARM_VERSION=3.5.0

ENV DEBIAN_FRONTEND=noninteractive
ENV SWARM_VERSION=${SWARM_VERSION}

# Install required packages (including X11 libraries for GUI)
RUN apt-get update && \
    apt-get install -y wget unzip libxext6 libxi6 libxtst6 libxrender1 libxrandr2 && \
    rm -rf /var/lib/apt/lists/*

# Download and unpack Swarm
RUN wget -q "https://volcanoes.usgs.gov/software/swarm/bin/swarm-${SWARM_VERSION}-bin.zip" -O /tmp/swarm.zip && \
    unzip -q /tmp/swarm.zip -d /opt && \
    rm /tmp/swarm.zip

WORKDIR /opt/swarm-${SWARM_VERSION}

# Ensure the launcher script is executable
RUN chmod +x ./swarm.sh

# Copy Swarm.config to avoid Swarm 3.5.0 config creation/parsing bug
COPY Swarm.config /opt/swarm-${SWARM_VERSION}/Swarm.config

# Copy entrypoint to handle DISPLAY
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run Swarm (requires X11 display - use X11 forwarding)
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./swarm.sh"]
