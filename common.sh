# Shared preflight for homelab bootstrap scripts.
# Intended to be sourced by the executable scripts in this repository.

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
