# Writebook on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/writebook)

One-click Railway template for [Writebook](https://github.com/basecamp/writebook), the free publishing app from 37signals: write books, manuals and documentation in Markdown and publish them on the web, publicly or privately.

This repository wraps the **official, unmodified** image `ghcr.io/basecamp/writebook` with the few things Railway needs. It is a community template and is not affiliated with 37signals.

## What the template does for you

| Problem with the raw image on Railway | What this template does |
|---|---|
| Railway volumes are owned by root, Writebook runs as uid 1000 and can't write its database | Fixes the volume's ownership on boot, then drops root privileges |
| Web and job process counts follow the host's CPU count (the whole Railway machine), which inflates memory and cost | Caps them with `WEB_CONCURRENCY` and `JOB_CONCURRENCY` (1 each by default) |
| The first visitor to the URL becomes administrator | Creates your administrator on first boot from `ADMIN_EMAIL`, with a generated password |
| Needs a `SECRET_KEY_BASE` | Generated at deploy time (and regenerated on the volume if ever removed) |
| Listens on ports 80/443 with its own TLS | Serves plain HTTP on 8080 behind Railway's HTTPS, health check on `/up` |

## Deploy

1. Click **Deploy on Railway** and enter the email address you want to sign in with.
2. Wait for the first deploy (about two minutes), then open the generated `*.up.railway.app` URL.
3. Sign in with that email and the `ADMIN_PASSWORD` value from the service's **Variables** tab. Change the password from your profile afterwards.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `ADMIN_EMAIL` | *(you provide it)* | Email of the administrator created on first boot |
| `ADMIN_PASSWORD` | generated | Password of that administrator. Only used on first boot |
| `ADMIN_NAME` | `Admin` | Display name of that administrator |
| `SECRET_KEY_BASE` | generated | Signs sessions and cookies. Don't change it once set |
| `WEB_CONCURRENCY` | `1` | Web processes. Raise only for heavy traffic |
| `JOB_CONCURRENCY` | `1` | Background job workers |
| `WRITEBOOK_VERSION` | `1.2.4` | Official image tag to build from |

Data (SQLite database, uploaded images) lives in the volume mounted at `/rails/storage`.

## Updating Writebook

Set `WRITEBOOK_VERSION` to a newer tag from the [official image](https://github.com/basecamp/writebook/pkgs/container/writebook) and redeploy. Database migrations run automatically on boot.

## Custom domain

Add it under **Settings → Networking** of the service. Railway issues the certificate; nothing to change in Writebook.

## Licence

Writebook is © 37signals, released under the MIT licence. The files in this repository are also MIT-licensed.
