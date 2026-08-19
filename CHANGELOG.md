# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [ToDo]

- some documentation in [doc](./doc/) directory
- add simple init functionality

## [Unreleased](https://github.com/march42/docker-testing-checking/compare/v0.1.0...HEAD)

[HEAD](https://github.com/march42/docker-testing-checking/tree/HEAD)

## [v0.1.0](https://github.com/march42/docker-testing-checking/tree/v0.1.0)

### Added

- [image-networking](./image-networking/) with useful networking tools
- copied [docker-healthcheck.sh](./image-networking/docker-healthcheck.sh) to [script](./script/)
- copied [docker-entrypoint.sh](./image-with-appuser/docker-entrypoint.sh) to [script](./script/)
- image file `/app/IMG_VERSION` with specific build information

### Changed

- reworked [image-with-appuser](./image-with-appuser/)
  - some debugging output in [docker-entrypoint.sh](./image-with-appuser/docker-entrypoint.sh)
  - allow duplicate uid/gid, despite security risk
  - bumped Alpine linux default version to 3.24
  - `ARG ALPINE_VERSION` to specify version to be used e.g. `--build-arg ALPINE_LINUX=3.22`
  - `ARG IMG_VERSION` to specify `IMG_VERSION` for `LABEL version=` e.g. `--build-arg IMG_VERSION=20260820-appuser`
  - `ARG IMG_DEBUG` to specify debugging default on build e.g. `--build-arg IMG_DEBUG=true`
  - `ENV IMG_DEBUG` to specify debugging default on runtime e.g. `--env IMG_DEBUG=""`
  - additional documentation in [README](./image-with-appuser/README.md)
- some documentation in [README](./README.md)

## [0.0.0](https://github.com/march42/docker-testing-checking/tree/v0.0.0) - 2026-08-20

### Added

- [image-with-appuser](./image-with-appuser/) simple image with support for running under UID/GID
  - image user account `appuser`
  - image user group `appgroup`
  - build with specified UID/GID e.g. `--build-arg APP_UID=10444 --build-arg APP_GID=10013`
    - `ARG APP_UID` to specify appuser uid on build e.g. `--build-arg APP_UID=10444`
    - `ARG APP_GID` to specify appgroup gid on build e.g. `--build-arg APP_GID=10013`
  - run with specified UID/GID e.g. `--env HOST_UID=10243 --env HOST_GID=65535`
    - `ENV HOST_UID` to specify appuser uid on runtime e.g. `--env HOST_UID=10243`
    - `ENV HOST_GID` to specify appgroup gid on runtime e.g. `--env HOST_GID=65535`
  - `/docker-entrypoint.sh` script
    - modify group appgroup gid to `HOST_GID`
    - modify user appuser uid to `HOST_UID`, primary group to `HOST_GID`, additional group `appgroup`

## [TEMPLATE]

### Added

for new features

### Changed

for changes in existing functionality

### Deprecated

for soon-to-be removed features

### Removed

for now removed features

### Fixed

for any bug fixes

### Security

in case of vulnerabilities
