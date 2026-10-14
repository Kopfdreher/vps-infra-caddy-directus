# Frontend agent brief

Build two static React sites that Caddy can serve and that read content from Directus. Do not add a Node server, a database client, or another Compose service.

## How this server is wired

Caddy is the only public process. It terminates HTTPS and serves files from disk:

| Host | Files on disk | URL inside the Caddy container |
|---|---|---|
| `BROTHER_DOMAIN` | `/opt/webstack/frontends/brother` | `/srv/brother` |
| `WIFE_DOMAIN` | `/opt/webstack/frontends/wife` | `/srv/wife` |
| `CMS_DOMAIN` | none | reverse proxy to `directus:8055` |

`try_files {path} /index.html` is already set. Client-side routes work if the production build is a single `index.html` plus assets.

Directus stores data in SQLite on the server. The browser never connects to SQLite. The browser talks only to the public Directus URL, `https://<CMS_DOMAIN>`.

Current hostnames, until real domains replace them:

- `https://brother.157.180.77.116.sslip.io`
- `https://wife.157.180.77.116.sslip.io`
- `https://cms.157.180.77.116.sslip.io`

## How to build

Use Vite and React. One app per site, or one app built twice with a different `VITE_SITE` value. The production command must be `vite build`. The output directory must be `dist/`.

Deploy by copying the contents of `dist/` into the matching frontend folder, not the folder itself:

```bash
rsync -a --delete dist/ /opt/webstack/frontends/brother/
rsync -a --delete dist/ /opt/webstack/frontends/wife/
```

`index.html` has to sit directly in `brother/` or `wife/`. Caddy will not look in a nested `dist/` directory.

Set the asset base to `/` so JS and CSS load from the site root. Do not proxy `/items` through the frontend host. The API lives on the CMS host.

## How to read Directus

Use the public REST API. No SDK is required.

```http
GET https://<CMS_DOMAIN>/items/<collection>?fields=*.*
```

Public content must be readable by the Directus public role. Do not put the admin email or admin password in the frontend. Do not call `/auth/login` from these sites.

Configure the CMS host at build time:

```
VITE_DIRECTUS_URL=https://cms.157.180.77.116.sslip.io
```

Read it with `import.meta.env.VITE_DIRECTUS_URL`. A missing value should fail the build, not silently call localhost.

In Directus, under Settings → Project Settings, set the project URL to that same CMS origin. Under Settings → Access Policies, allow the public role to read the collections the sites render. For uploaded images, request the file id and build the URL as:

```
${VITE_DIRECTUS_URL}/assets/<file-id>
```

CORS must allow the two site origins. In Directus that is the `CORS_ORIGIN` environment variable, or the CORS settings in the project. Allow:

- `https://brother.157.180.77.116.sslip.io`
- `https://wife.157.180.77.116.sslip.io`

## What not to add

- No `output: 'server'` or React Server Components. Caddy cannot run them.
- No Prisma, SQLite, or `better-sqlite3` in the frontend.
- No changes to `docker-compose.yml` unless a Directus CORS variable is required.
- No admin token in source control or in `VITE_` variables. Those values are baked into the public JS bundle.
