# swarm-seismic-image

Docker image for running **USGS Swarm** for real-time seismic waveform analysis. This repository contains a containerized Swarm application that can connect to various seismic data sources (GeoNet FDSN, IRIS, SeedLink, etc.).

## Overview

This is a containerized application that runs USGS Swarm, a real-time seismic waveform display and analysis tool. Swarm is a GUI application that requires a graphical display and Java 8 or greater.

Swarm can connect to multiple data sources including:

* **FDSN Web Services** (GeoNet, IRIS, etc.)
* **SeedLink servers**
* **Earthworm wave servers**
* **Winston wave servers**
* **Wave files**

Swarm processes and visualizes seismic data, and can export events in QuakeML format for use by other applications.

## Quick Start

### Build the Image

```bash
docker build -t swarm-seismic-image:latest .
```

### Run Swarm

Swarm requires X11 display. Ensure you have an X11 server running, then:

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  swarm-seismic-image:latest
```

**Note:** If `DISPLAY` is empty, ensure X11 is running and set it explicitly:

```bash
export DISPLAY=:0
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  swarm-seismic-image:latest
```

## Configuration

### Build Arguments

The Dockerfile supports configurable build arguments:

* `JAVA_BASE_IMAGE` (default: `eclipse-temurin:8-jre`) - Java base image
* `SWARM_VERSION` (default: `3.5.0`) - Swarm version to install

**Example with custom build args:**

```bash
docker build \
  --build-arg JAVA_BASE_IMAGE=eclipse-temurin:8-jre-alpine \
  --build-arg SWARM_VERSION=3.5.0 \
  -t swarm-seismic-image:custom .
```

### Runtime Configuration

#### Data Source Configuration

Swarm configuration is stored in `/root/.swarm`. Mount a volume to persist configuration:

```bash
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd)/swarm-config:/root/.swarm \
  swarm-seismic-image:latest
```

**Example: Configuring GeoNet FDSN**

In Swarm GUI:

```
Dataselect: https://service-nrt.geonet.org.nz/fdsnws/dataselect/1/query
Station:    https://service-nrt.geonet.org.nz/fdsnws/station/1/query
Network:    NZ
```

**Example: Configuring SeedLink**

In Swarm, configure SeedLink server:

```
Host: your-seedlink-server.com
Port: 18000
```

## Local Development

### Prerequisites

* Docker
* X11 server (for GUI)

### Development Workflow

1. **Build locally:**

   ```bash
   docker build -t swarm-seismic:local .
   ```

2. **Run with X11:**

   ```bash
   docker run --rm -it \
     -e DISPLAY=$DISPLAY \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     swarm-seismic:local
   ```

3. **Mount config directory:**

   ```bash
   docker run --rm -it \
     -e DISPLAY=$DISPLAY \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     -v $(pwd)/config:/root/.swarm \
     swarm-seismic:local
   ```

## Production Deployment

Swarm is designed as a GUI application for interactive use. For production monitoring, run on a system with X11 display or use remote X11 forwarding.

## CI/CD

The repository includes GitHub Actions workflows that:

* Build Docker images on push to `main`
* Push to GitHub Container Registry (GHCR)
* Support semantic versioning with tags
* Create GitHub releases for version tags

Images are available at: `ghcr.io/platformfuzz/swarm-seismic-image`

## Requirements

* **Java 8** - Swarm requires Java 8 (provided by eclipse-temurin:8-jre)
* **X11 Display** - Swarm is a GUI application requiring X11
* **Data Sources** - Access to seismic data sources (SeedLink, FDSN, etc.)

## Project Structure

```
swarm-seismic-image/
├── Dockerfile                 # Swarm image with configurable build args
├── Swarm.config               # Pre-created config to avoid Swarm 3.5.0 bug
├── README.md                  # This file
├── LICENSE                    # MIT License
├── .gitignore                 # Git ignore patterns
└── .github/
    └── workflows/
        ├── ci.yml             # CI workflow for PRs
        └── build-and-release.yml  # CI/CD to build and push to GHCR
```

## Important Notes

* **Swarm is a GUI application** - It requires X11 display forwarding to run
* **Swarm 3.5.0 config bug** - A pre-created `Swarm.config` file is included to work around a known bug in Swarm's config creation code
* **Export capabilities** - Swarm can export events in QuakeML format, which can be consumed by other applications via file-based integration
* **Client-only** - Swarm consumes data from various sources but cannot serve as an upstream data source itself

## License

MIT License - see LICENSE file for details.

## Related Projects

* [geomag-api-image](https://github.com/platformfuzz/geomag-api-image) - Backend API service
* [geomag-web-image](https://github.com/platformfuzz/geomag-web-image) - Web dashboard frontend
