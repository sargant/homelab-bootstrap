#!/usr/bin/env bash
# Updates a fresh Debian 13 host and installs a small set of useful baseline
# command-line tools. Git is deliberately omitted because it is considered a
# bootstrap prerequisite for retrieving this repository.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot determine operating system; /etc/os-release is missing." >&2
  exit 1
fi

. /etc/os-release

if [[ "${ID:-}" != "debian" || "${VERSION_ID:-}" != "13" ]]; then
  echo "This script requires Debian 13; detected ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

apt-get update
apt-get full-upgrade -y

apt-get install -y \
  ca-certificates \
  curl \
  wget \
  nfs-common \
  rsync \
  jq \
  unzip \
  iputils-ping \
  dnsutils \
  lsof \
  hx \
  tmux \
  ripgrep \
  btop \
  gdu

echo "Done. System updated and useful tools installed."
