# VPS infrastructure

Ansible prepares a fresh Ubuntu VPS and starts Caddy and Directus with rootless Docker. The site hostnames are `https://web.<ip>.sslip.io` and `https://cms.<ip>.sslip.io`.

## GitHub settings

In **Settings → Environments → Deploy**, add:

| Kind | Name | Used for |
|---|---|---|
| Variable | `VPS_IP` | Server address and the sslip.io hostnames |
| Variable | `ADMIN_EMAIL` | Directus admin email, written to `.env` on the server |
| Secret | `ADMIN_PASSWORD` | Directus admin password, written once to `secrets/admin_password.txt` |
| Secret | `DEPLOY_SSH_KEY` | Private key installed for the `deploy` user |
| Secret | `ROOT_PASSWORD` | Hetzner root password, used only by Setup VPS |

`ROOT_PASSWORD` is the password Hetzner shows after a rebuild. Setup logs in with it, installs the deploy key, then turns password login off. Maintain does not use that password.

`inventory.ini` is not stored in git. Each workflow writes it from `VPS_IP` before Ansible runs.

**Actions → Setup VPS** logs in as `root`. Use it once on a new or rebuilt server. It creates `deploy` and then turns off root SSH.

**Actions → Maintain VPS** logs in as `deploy`. Use it for later changes.

The admin password is applied only when the secret file does not exist yet. It does not change an admin user Directus has already created.

## What the playbook installs

- User `deploy`, that user’s SSH key, and passwordless sudo
- UFW allowing 22, 80, and 443 (TCP), plus 443 (UDP)
- SSH drop-in that disables root and password login
- Rootless Docker and the Compose stack in `/home/deploy/vps-infra`
- Directus key and secret generated on the server
- Frontend files served from `/var/www/frontend-main`
