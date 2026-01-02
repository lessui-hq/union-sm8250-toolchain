# RK3566 Toolchain Docker Image

Cross-compilation toolchain for Rockchip RK3566 devices (RGB30, RG353P, etc.) running LessOS.

## Overview

This Docker image provides a pre-built toolchain for building LessUI on RK3566-based devices. The toolchain is extracted from a LessOS build and includes SDL2, librga, and all other libraries that LessUI links against.

## Usage

The image is automatically built and published by GitHub Actions to `ghcr.io/lessui-hq/union-rk3566-toolchain:latest`.

From the LessUI repository:
```bash
make build PLATFORM=RK3566
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

Extracted from LessOS RK3566 build. To update, build LessOS for RK3566 and package the `build.LessOS-RK3566.aarch64/toolchain/` directory.
