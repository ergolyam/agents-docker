# agents-docker
This project builds **small container images for Codex CLI and Maki** from the [openai/codex](https://github.com/openai/codex) and [tontinton/maki](https://github.com/tontinton/maki) repos. It uses multi-stage builds to compile the Rust CLIs and ships them with a minimal runtime.

## Use from registry

- Pull the published images:
    ```bash
    docker pull ghcr.io/ergolyam/agents-docker/codex:latest
    docker pull ghcr.io/ergolyam/agents-docker/maki:latest
    ```

- Run Codex (mount your workspace + state):
    ```bash
    docker run -it --rm \
      -v "${PWD}":/work \
      -v codex-data:/data \
      -p 127.0.0.1:1455:1455 \
      ghcr.io/ergolyam/agents-docker/codex:latest
    ```

- Run Maki:
    ```bash
    docker run -it --rm \
      -v "${PWD}":/work \
      -v maki-data:/data \
      ghcr.io/ergolyam/agents-docker/maki:latest
    ```

- Arguments after the image name are passed to the CLI. Codex starts with `--no-daemon`.
- Both images support `:alpine`, `:void`, `:debian`, `:fedora`, and `:nix`. `:latest` uses Alpine.

## Build & run locally

- Build the Codex binary layer (set `CODEX_VERSION` to a compatible upstream `rust-v...` tag):
    ```bash
    docker build -t localhost/codex-base \
      --build-arg VERSION="${CODEX_VERSION}" \
      -f codex/dockerfile ./codex
    ```

- Or build the Maki binary layer (set `MAKI_VERSION` to a compatible upstream `v...` tag):
    ```bash
    docker build -t localhost/maki-base \
      --build-arg VERSION="${MAKI_VERSION}" \
      -f maki/dockerfile ./maki
    ```

- Build the runnable image:
    ```bash
    docker build -t localhost/codex-cli \
      --build-arg FINAL_IMAGE=docker.io/alpine:3.24 \
      --build-arg BASE_IMAGE=localhost/codex-base \
      -f distro/dockerfile ./distro
    ```
    - For Maki, use `localhost/maki-base` and tag the result `localhost/maki-cli`.
    - For a different distro, change `FINAL_IMAGE` (e.g. `docker.io/debian:trixie-slim`).

- Run it (mount your workspace + state):
    ```bash
    docker run -it --rm \
      -v "${PWD}":/work \
      -v codex-data:/data \
      -p 127.0.0.1:1455:1455 \
      localhost/codex-cli
    ```

## Build arguments

| Argument      | Description                                                         |
|---------------|---------------------------------------------------------------------|
| `VERSION`     | Upstream Codex or Maki tag to build.                                |
| `FINAL_IMAGE` | Runtime image for the final layer.                                  |
| `BASE_IMAGE`  | Image providing the compiled binaries and entrypoint in `/out/`.     |
| `DISTRO`      | Declared but unused; dependencies are selected by package manager.  |
| `SSH_VERSION` | OpenSSH version to build (default: `10.4p1`).                      |
| `TARGETARCH`  | Target architecture for `docker-remote` (`amd64` or `arm64`).       |

## Environment Variables

| Variable     | Description                                                     |
|--------------|-----------------------------------------------------------------|
| `CODEX_HOME` | Set to `/data` by the Codex entrypoint (state/config directory). |
| `MAKI_HOME`  | Set to `/data` by the Maki entrypoint (state/config directory).  |

## Features

- **Slim runtime**: includes CLI dependencies, `ssh`, `scp`, and `podman-remote`.
- **Multi‑distro builds**: Alpine, Void, Debian, Fedora, and Nix supported via build args.
- **Multi‑arch publishing**: GitHub Actions builds and publishes amd64 + arm64 manifests.
- **Upstream builds**: builds the latest matching upstream tags with local patches.
