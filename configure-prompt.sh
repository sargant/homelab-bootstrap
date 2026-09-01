#!/usr/bin/env bash
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

TARGET=/etc/bash.bashrc

if grep -q '^# homelab prompt$' "$TARGET"; then
    echo "Prompt already configured in $TARGET; refusing to modify it." >&2
    exit 1
fi

cat >>"$TARGET" <<'EOF'

# homelab prompt
if (( EUID == 0 )); then
    USER_COLOUR='\[\e[1m\e[38;5;203m\]'
else
    USER_COLOUR='\[\e[1m\e[38;5;231m\]'
fi

HOST_COLOUR='\[\e[38;5;114m\]'
PATH_COLOUR='\[\e[38;5;117m\]'

PS1='\n'"${HOST_COLOUR}"'\h\[\e[0m\]:'"${PATH_COLOUR}"'\w\[\e[0m\]\n'"${USER_COLOUR}"'\u\[\e[0m\] \$ '
EOF

echo "Done. Custom prompt added to $TARGET. Start a new shell to use it."
