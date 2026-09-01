#!/usr/bin/env bash
# Bootstrap SSH access on a fresh Debian 13 host.
# Installs OpenSSH/curl, pulls root authorized keys from GitHub,
# and disables password/keyboard-interactive SSH authentication.
# Root password login remains available on the local TTY.
# Fails rather than overwriting an existing SSH hardening drop-in.
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

KEYS_URL="${KEYS_URL:-https://github.com/sargant.keys}"
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
SSHD_DROPIN="/etc/ssh/sshd_config.d/00-root-keys-only.conf"

if [[ -e "$SSHD_DROPIN" ]]; then
  echo "$SSHD_DROPIN already exists; refusing to overwrite it." >&2
  exit 1
fi

apt-get update
apt-get install -y curl openssh-server

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
