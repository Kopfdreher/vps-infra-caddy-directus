# VPS infrastructure

Ansible prepares a fresh Ubuntu VPS and starts Caddy and Directus with rootless Docker. The site hostnames are `https://web.<ip>.sslip.io` and `https://cms.<ip>.sslip.io`.

## GitHub settings

In **Settings → Secrets and variables → Actions**:

| Kind | Name | Used for |
|---|---|---|
| Variable | `VPS_IP` | Server address and the sslip.io hostnames |
| Variable | `ADMIN_EMAIL` | Directus admin email, written to `.env` on the server |
| Secret | `ADMIN_PASSWORD` | Directus admin password, written once to `secrets/admin_password.txt` |
| Secret | `DEPLOY_SSH_KEY` | Private key for `~/.ssh/hetzner_deploy` |

The public half of that key must be installed for `root` on a new server (Hetzner SSH key at create time).

`inventory.ini` is not stored in git. **Actions → Deploy VPS → Run workflow** writes it from `VPS_IP` and the SSH user, then runs the playbook.

On the first run against a new server, set the SSH user to `root`. After that, leave it as `deploy`. Root login and password login are turned off at the end of the first run.

The admin password is applied only when the secret file does not exist yet. It does not change an admin user Directus has already created.

## What the playbook installs

- User `deploy`, that user’s SSH key, and passwordless sudo
- UFW allowing 22, 80, and 443 (TCP), plus 443 (UDP)
- SSH drop-in that disables root and password login
- Rootless Docker and the Compose stack in `/home/deploy/vps-infra`
- Directus key and secret generated on the server
- Frontend files served from `/var/www/frontend-main`
