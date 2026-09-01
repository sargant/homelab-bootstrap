#!/usr/bin/env bash
# Updates a fresh Debian 13 host and installs a small set of useful baseline
# command-line tools. Git is deliberately omitted because it is considered a
# bootstrap prerequisite for retrieving this repository.
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

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
