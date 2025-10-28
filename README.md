# Blue/Green Nginx Upstreams (Auto-Failover + Manual Toggle)


This repository implements the Stage 2 DevOps task: run two ready-to-run Nodejs app images (blue & green) behind Nginx using Docker Compose. The Nginx config is templated and tuned for fast failover and in-request retries so clients never receive failures when the active app dies.


## Files
See the repo root for:
- `docker-compose.yml`
- `.env.example` (copy to `.env` and fill values as CI/grader will set them)
- `nginx/` (template + entrypoint)
- `README.md` (this file)
- `DECISION.md` (explain decisions)
- `PART_B_RESEARCH.md` (the research doc you should paste into Google Docs)


## How to run locally (manual verification)
1. Copy the example env:
```bash
cp .env.example .env
# Edit .env if necessary (or let the grader set variables)