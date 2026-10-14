# Web stack

One Ubuntu VPS, Docker, Caddy, and Directus. Two static sites and the CMS sit behind Caddy.

## On a new server

As root:

```bash
bash init-server.sh
```

Clone this repo into `/opt/webstack` (the directories already exist), then:

```bash
cd /opt/webstack
cp .env.example .env
# edit .env: real domains, email, and random KEY/SECRET/password
docker compose up -d
```

Point the three domains at the server. Caddy requests certificates on the first visit.

Put the brother site in `/opt/webstack/frontends/brother` and the wife site in `/opt/webstack/frontends/wife`.

`.env` stays on the server. It is not committed.
