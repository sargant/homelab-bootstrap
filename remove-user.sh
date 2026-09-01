#!/usr/bin/env bash
# Removes a non-root user created during Debian installation.
# Deletes the account and its home directory; refuses UID 0 and active users.
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

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
