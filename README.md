# SM8250 Toolchain Docker Image

Cross-compilation toolchain for Qualcomm SM8250 devices running LessOS.

## Overview

This Docker image provides a pre-built toolchain for building LessUI on SM8250-based devices. The toolchain is extracted from a LessOS build and includes SDL2 and all other libraries that LessUI links against.

## Usage

The image is automatically built and published by GitHub Actions to `ghcr.io/lessui-hq/union-sm8250-toolchain:latest`.

From the LessUI repository:
```bash
make build PLATFORM=SM8250
```

## Local Development

```bash
make shell  # Enters the toolchain container
```

The container's `/root/workspace` is bound to `./workspace` by default.

## Toolchain Details

- **Location:** `/opt/toolchain`
- **Target triplet:** `aarch64-rocknix-linux-gnu`
- **Sysroot:** `/opt/toolchain/aarch64-rocknix-linux-gnu/sysroot`

## Toolchain Source

Extracted from LessOS SM8250 build. To update, build LessOS for SM8250 and package the `build.LessOS-SM8250.aarch64/toolchain/` directory.
