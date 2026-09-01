#!/usr/bin/env bash
set -euo pipefail

KEYS_URL="${KEYS_URL:-https://github.com/sargant.keys}"
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
SSHD_DROPIN="/etc/ssh/sshd_config.d/00-root-keys-only.conf"

if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if [[ -e "$SSHD_DROPIN" ]]; then
  echo "$SSHD_DROPIN already exists; refusing to overwrite it." >&2
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y curl openssh-server

echo "Installing root SSH keys from ${KEYS_URL}..."
keys_tmp="$(mktemp)"
trap 'rm -f "$keys_tmp"' EXIT

curl -fsSL "$KEYS_URL" -o "$keys_tmp"

if [[ ! -s "$keys_tmp" ]]; then
  echo "No SSH keys were returned by ${KEYS_URL}; refusing to change SSH access." >&2
  exit 1
fi

install -d -o root -g root -m 700 /root/.ssh
install -o root -g root -m 600 "$keys_tmp" "$AUTHORIZED_KEYS"

echo "Configuring SSH for key-only remote access..."
install -d -o root -g root -m 755 /etc/ssh/sshd_config.d

cat >"$SSHD_DROPIN" <<'EOF'
PermitRootLogin prohibit-password
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
chmod 644 "$SSHD_DROPIN"

if ! /usr/sbin/sshd -t; then
  echo "sshd configuration validation failed; removing $SSHD_DROPIN." >&2
  rm -f "$SSHD_DROPIN"
  exit 1
fi

systemctl reload ssh

echo "Done. SSH password authentication is disabled; local TTY password login is unchanged."
