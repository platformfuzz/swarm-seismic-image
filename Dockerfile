ARG JAVA_BASE_IMAGE=eclipse-temurin:8-jre
ARG SWARM_VERSION=3.5.0

FROM ${JAVA_BASE_IMAGE}

ARG SWARM_VERSION=3.5.0

ENV DEBIAN_FRONTEND=noninteractive
ENV SWARM_VERSION=${SWARM_VERSION}
# DISPLAY will be set by entrypoint or X11 forwarding

# Install required packages (including Xvfb for virtual display)
RUN apt-get update && \
    apt-get install -y wget unzip xvfb libxtst6 libxi6 && \
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

# Create entrypoint script to start Xvfb and run Swarm
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start Xvfb virtual display and run Swarm
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./swarm.sh"]
