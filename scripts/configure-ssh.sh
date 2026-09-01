#!/usr/bin/env bash
set -euo pipefail

KEYS_URL="${KEYS_URL:-https://github.com/sargant.keys}"
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
SSHD_DROPIN="/etc/ssh/sshd_config.d/10-homelab-bootstrap.conf"

if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

packages=()
command -v curl >/dev/null 2>&1 || packages+=(curl)
[[ -x /usr/sbin/sshd ]] || packages+=(openssh-server)

if ((${#packages[@]})); then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
fi

echo "Installing root SSH keys from ${KEYS_URL}..."
keys_tmp="$(mktemp)"
dropin_backup=""
trap 'rm -f "$keys_tmp" "$dropin_backup"' EXIT

curl -fsSL "$KEYS_URL" -o "$keys_tmp"

if [[ ! -s "$keys_tmp" ]]; then
  echo "No SSH keys were returned by ${KEYS_URL}; refusing to change SSH access." >&2
  exit 1
fi

install -d -o root -g root -m 700 /root/.ssh
install -o root -g root -m 600 "$keys_tmp" "$AUTHORIZED_KEYS"

echo "Configuring root SSH login as key-only..."
install -d -o root -g root -m 755 /etc/ssh/sshd_config.d

if [[ -f "$SSHD_DROPIN" ]]; then
  dropin_backup="$(mktemp)"
  cp -a "$SSHD_DROPIN" "$dropin_backup"
fi

cat >"$SSHD_DROPIN" <<'EOF'
# Managed by homelab-bootstrap/scripts/configure-ssh.sh
PubkeyAuthentication yes
PermitRootLogin prohibit-password
EOF
chmod 644 "$SSHD_DROPIN"

if ! /usr/sbin/sshd -t; then
  echo "sshd configuration validation failed; rolling back." >&2
  if [[ -n "$dropin_backup" ]]; then
    cp -a "$dropin_backup" "$SSHD_DROPIN"
  else
    rm -f "$SSHD_DROPIN"
  fi
  exit 1
fi

systemctl reload ssh

echo "Done. Root SSH login is key-only; local TTY password login is unchanged."
