# homelab-bootstrap

Small, opinionated bootstrap scripts for fresh Debian 13 homelab installs.

The scripts are intended to make new hosts consistent without turning provisioning into a framework.

## SSH bootstrap

`configure-ssh.sh` installs OpenSSH and curl, copies root SSH keys from `https://github.com/sargant.keys`, and disables password-based SSH authentication while leaving local TTY password login available.

Run as root on a fresh Debian 13 install:

```bash
./configure-ssh.sh
```
