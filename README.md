# render-relay-sg

A tiny Docker image that runs an Xray VLESS + WebSocket relay on [Render](https://render.com)'s free tier (Singapore region). It exists because Render's "Docker Command" field cannot run inline shell reliably, so the startup logic lives in this image instead.

## How it works

```
Render env var XRAY_CONFIG  (the full Xray JSON config, one line, secret)
        │  read at container start by entrypoint.sh
        ▼
/etc/xray/config.json
        │  exec
        ▼
xray run  →  VLESS + WS inbound on port 10000
```

- `Dockerfile` — based on `teddysun/xray:latest`; adds only the entrypoint script.
- `entrypoint.sh` — writes `$XRAY_CONFIG` to `/etc/xray/config.json`, then `exec`s Xray. **No secrets are stored in this repo** — the config (UUID, WS path) only ever lives in Render's environment variables.
- Render terminates HTTPS at its edge and forwards WebSocket traffic to port 10000 (Render's default `$PORT`).

## Deploy on Render (for a human or an agent redoing this)

1. New → Web Service → **Public Git Repository** → paste this repo's URL. No GitHub account linking needed.
2. Settings: Runtime = Docker, Region = Singapore, Instance = Free, Branch = main.
3. Environment variable: `XRAY_CONFIG` = the one-line Xray JSON (VLESS inbound, `port: 10000`, `listen: 0.0.0.0`, WS network). The current production values are kept by the operator, not here.
4. Deploy. Success = logs show Xray's startup lines and the instance stays up (no exit-127 loop).
5. Client side: VLESS + WS + TLS, server = `<service>.onrender.com`, port 443, host/SNI = same domain, WS path and UUID from the config.

## Operations notes

- **Free tier spins down** after ~15 min without traffic; the next request takes 50+ s to wake it. A light keepalive ping every ~10 min keeps it warm; free allowance is 750 instance-hours/month, so one always-on service fits.
- This is a **disposable backup node**, not a primary. Render may suspend free services with unusually high outbound volume — keep traffic light.
- To rotate credentials: change `XRAY_CONFIG` in Render (new UUID / WS path) and redeploy. Nothing in this repo changes.
- To kill it: delete the Render service. This repo can stay; it contains nothing sensitive.

## Why the entrypoint exists

Three inline Docker Command variants (`sh -c '…'`, bare script, `/bin/sh -c "…"`) were tried on 2026-11-23; Render's launcher mangled all of them (env expansion + quote stripping → the script text was executed as a single program name, exit 127). Baking the script into the image is the fix.
# render-relay-sg

A tiny Docker image that runs an Xray VLESS + WebSocket relay on [Render](https://render.com)'s free tier (Singapore region). It exists because Render's "Docker Command" field cannot run inline shell reliably, so the startup logic lives in this image instead.

## How it works

```
Render env var XRAY_CONFIG  (the full Xray JSON config, one line, secret)
        │  read at container start by entrypoint.sh
        ▼
/etc/xray/config.json
        │  exec
        ▼
xray run  →  VLESS + WS inbound on port 10000
```

- `Dockerfile` — based on `teddysun/xray:latest`; adds only the entrypoint script.
- `entrypoint.sh` — writes `$XRAY_CONFIG` to `/etc/xray/config.json`, then `exec`s Xray. **No secrets are stored in this repo** — the config (UUID, WS path) only ever lives in Render's environment variables.
- Render terminates HTTPS at its edge and forwards WebSocket traffic to port 10000 (Render's default `$PORT`).

## Deploy on Render (for a human or an agent redoing this)

1. New → Web Service → **Public Git Repository** → paste this repo's URL. No GitHub account linking needed.
2. Settings: Runtime = Docker, Region = Singapore, Instance = Free, Branch = main.
3. Environment variable: `XRAY_CONFIG` = the one-line Xray JSON (VLESS inbound, `port: 10000`, `listen: 0.0.0.0`, WS network). The current production values are kept by the operator, not here.
4. Deploy. Success = logs show Xray's startup lines and the instance stays up (no exit-127 loop).
5. Client side: VLESS + WS + TLS, server = `<service>.onrender.com`, port 443, host/SNI = same domain, WS path and UUID from the config.

## Operations notes

- **Free tier spins down** after ~15 min without traffic; the next request takes 50+ s to wake it. A light keepalive ping every ~10 min keeps it warm; free allowance is 750 instance-hours/month, so one always-on service fits.
- This is a **disposable backup node**, not a primary. Render may suspend free services with unusually high outbound volume — keep traffic light.
- To rotate credentials: change `XRAY_CONFIG` in Render (new UUID / WS path) and redeploy. Nothing in this repo changes.
- To kill it: delete the Render service. This repo can stay; it contains nothing sensitive.

## Why the entrypoint exists

Three inline Docker Command variants (`sh -c '…'`, bare script, `/bin/sh -c "…"`) were tried on 2026-11-23; Render's launcher mangled all of them (env expansion + quote stripping → the script text was executed as a single program name, exit 127). Baking the script into the image is the fix.
