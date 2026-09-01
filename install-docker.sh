#!/usr/bin/env bash
# Installs Docker Engine from Docker's official apt repository on Debian 13.
# Adds Docker's signing key and stable apt source, then installs Engine, CLI,
# containerd, Buildx and the Compose plugin. Intended for fresh homelab hosts;
# if Docker already appears to be configured, the script exits rather than
# attempting to modify or replace an existing installation.
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

DOCKER_KEYRING="/etc/apt/keyrings/docker.asc"
DOCKER_SOURCE="/etc/apt/sources.list.d/docker.sources"

if command -v docker >/dev/null 2>&1 || [[ -e "$DOCKER_KEYRING" || -e "$DOCKER_SOURCE" ]]; then
  echo "Docker already appears to be configured; refusing to modify the existing setup." >&2
  exit 1
fi

apt-get update
apt-get install -y ca-certificates curl

install -d -m 755 /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o "$DOCKER_KEYRING"
chmod a+r "$DOCKER_KEYRING"

cat >"$DOCKER_SOURCE" <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: ${DOCKER_KEYRING}
EOF

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

docker version >/dev/null
docker compose version >/dev/null

echo "Done. Docker Engine and Docker Compose are installed and running."
