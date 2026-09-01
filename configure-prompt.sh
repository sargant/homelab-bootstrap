#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
    USER_COLOUR='\[\e[1m\e[38;5;203m\]'
else
    USER_COLOUR='\[\e[1m\e[38;5;231m\]'
fi

HOST_COLOUR='\[\e[38;5;114m\]'
PATH_COLOUR='\[\e[38;5;117m\]'

PROMPT_BLOCK=$(cat <<EOF

# homelab prompt
if (( EUID == 0 )); then
    USER_COLOUR='${USER_COLOUR}'
else
    USER_COLOUR='\[\e[1m\e[38;5;231m\]'
fi
HOST_COLOUR='${HOST_COLOUR}'
PATH_COLOUR='${PATH_COLOUR}'
PS1='\n'"\${HOST_COLOUR}"'\h\[\e[0m\]:'"\${PATH_COLOUR}"'\w\[\e[0m\]\n'"\${USER_COLOUR}"'\u\[\e[0m\] \$ '
EOF
)

TARGET=/root/.bashrc

if grep -q '^# homelab prompt$' "$TARGET" 2>/dev/null; then
    echo "Prompt already configured in $TARGET; refusing to modify it." >&2
    exit 1
fi

printf '%s\n' "$PROMPT_BLOCK" >> "$TARGET"

echo "Done. Custom prompt added to $TARGET. Start a new shell to use it."
