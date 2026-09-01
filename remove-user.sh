#!/usr/bin/env bash
# Removes a non-root user created during Debian installation.
# Deletes the account and its home directory; refuses UID 0 and active users.
set -euo pipefail

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

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME="$1"

if ! id "$USERNAME" >/dev/null 2>&1; then
  echo "User '$USERNAME' does not exist." >&2
  exit 1
fi

if [[ $(id -u "$USERNAME") -eq 0 ]]; then
  echo "Refusing to remove UID 0 user '$USERNAME'." >&2
  exit 1
fi

if pgrep -u "$USERNAME" >/dev/null 2>&1; then
  echo "User '$USERNAME' has running processes; stop them before removing the user." >&2
  exit 1
fi

userdel -r "$USERNAME"

echo "Done. User '$USERNAME' has been removed."
