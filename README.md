# swarm-seismic-image

Docker image for running **USGS Swarm** for real-time seismic waveform analysis. This repository contains a containerized Swarm application that can connect to various seismic data sources (GeoNet FDSN, IRIS, SeedLink, etc.).

## Overview

This is a containerized application that runs USGS Swarm, a real-time seismic waveform display and analysis tool. Swarm is a GUI application that requires X11 display forwarding.

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

### Run (Default - Uses Xvfb Virtual Display)

The container includes Xvfb and runs Swarm with a virtual display by default. This works out of the box:

```bash
docker run --rm -it swarm-seismic-image:latest
```

### Run with Host X11 Forwarding (Optional)

**For Windows + SSH into VM:**

1. **Install X11 server on Windows:**
   * [VcXsrv](https://sourceforge.net/projects/vcxsrv/) (free, recommended)
   * Start VcXsrv: "Multiple windows", "Start no client", allow public networks

2. **SSH with X11 forwarding:**

   ```bash
   ssh -X username@vm-host
   # Or trusted forwarding:
   ssh -Y username@vm-host
   ```

3. **Run container (DISPLAY is automatically forwarded via SSH):**

   ```bash
   docker run --rm -it \
     -e DISPLAY=$DISPLAY \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     swarm-seismic-image:latest
   ```

   **Note:** If `DISPLAY` is set (from X11 forwarding), the container uses it. Otherwise, it uses Xvfb automatically.

**On macOS:** Install XQuartz and use:

```bash
docker run --rm -it \
  -e DISPLAY=host.docker.internal:0 \
  swarm-seismic-image:latest
```

### Example with Custom Arguments

```bash
docker run --rm -it \
  -v $(pwd)/config:/root/.swarm \
  swarm-seismic-image:latest ./swarm.sh --nogui
```

## Configuration

### Build Arguments

The Dockerfile supports configurable build arguments:

* `JAVA_BASE_IMAGE` (default: `eclipse-temurin:8-jre`) - Java base image
  * Alternative: `eclipse-temurin:8-jre-alpine` for smaller image size
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
* X11 server (for GUI on Linux)
* XQuartz (for GUI on macOS)

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

### Basic Deployment

Swarm is designed as a GUI application for interactive use. For production monitoring, consider:

1. Running on a system with X11 display
2. Using remote X11 forwarding (SSH X11 forwarding)
3. Running in a VM with desktop environment

```bash
docker run -d \
  --name swarm-seismic \
  -e DISPLAY=:0 \
  -v /path/to/config:/root/.swarm \
  swarm-seismic-image:latest
```

### Export Directory

Swarm can export events in QuakeML format. Mount a volume for exports:

```bash
docker run -d \
  --name swarm-seismic \
  -e DISPLAY=:0 \
  -v /path/to/exports:/root/swarm-exports \
  swarm-seismic-image:latest
```

Configure Swarm to export to `/root/swarm-exports` for integration with upstream services.

## CI/CD

The repository includes GitHub Actions workflows that:

* Build Docker images on push to `main`
* Push to GitHub Container Registry (GHCR)
* Support semantic versioning with tags
* Create GitHub releases for version tags

Images are available at: `ghcr.io/platformfuzz/swarm-seismic-image`

## Requirements

* **Java 8** - Swarm requires Java 8 (provided by eclipse-temurin:8-jre)
* **X11/Xvfb** - Swarm is a GUI application; container includes Xvfb for virtual display
* **X11 Server (for GUI)** - If you want to see the GUI:
  * **Windows:** VcXsrv, X410, or Xming
  * **macOS:** XQuartz
  * **Linux:** Usually pre-installed
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
