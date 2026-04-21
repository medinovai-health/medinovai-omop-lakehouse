# CLAUDE.md — medinovai-omop-lakehouse

> This file is read by every Claude agent at the start of each session.
> Keep it accurate. It is the agent's primary source of truth about this repo.

## Purpose

**medinovai-omop-lakehouse** is a Phase E MedinovAI **data layer** service: PostgreSQL holds the [OMOP CDM v5.4](https://ohdsi.github.io/CommonDataModel/cdm54.html) core schema; **Trino** federates SQL analytics over that warehouse; a small **FastAPI** service exposes platform health/readiness and will grow into lakehouse APIs. Downstream consumers include cohort analytics, integration ETL, and research workspaces. All patient content must be tenant-scoped and non-PHI in logs.

## Compliance Tier

**Tier 2** — platform / infrastructure (data layer; may process de-identified or governed clinical analytics).

Applicable regulations: **HIPAA** and **GDPR** when connected to identifiable feeds (use BAA, encryption, audit); **21 CFR Part 11** when records support regulated decisions; design for **ISO 27001** controls and least-privilege access.

## Tech Stack

- Backend: Python 3.12 (FastAPI, uvicorn)
- Frontend: None
- Database: PostgreSQL 15 (OMOP CDM v5.4 core tables)
- Query engine: Trino (PostgreSQL catalog)
- Cache: None (add Redis only with spec)
- Messaging: None (Phase E — wire to platform bus when specified)
- Infrastructure: Docker Compose (local); Kubernetes reference TBD
- Monitoring: Structured logs; platform OTEL TBD

## How to Start the Dev Server

```bash
bash init.sh
```

- API: `http://localhost:28000` (host port)
- PostgreSQL: `localhost:25432` (user `omop`, db `omop` — dev password in `docker-compose.yml`, replace in prod)
- Trino UI/API: `http://localhost:18090`
- Health: `GET http://localhost:28000/health` → 200 JSON

## How to Run Unit Tests

```bash
pip install -r requirements.txt
pytest tests/unit/
```

Minimum coverage: **80%** when test suite exists (scaffold has no tests yet — add under TDD workflow).

## How to Run End-to-End Tests

```bash
pytest tests/e2e/
# or: curl-based checks after init.sh
```

## Coding Conventions (MedinovAI Standard)

- Constants: `E_VARIABLE` (uppercase, `E_` prefix)
- Variables: `mos_variableName` (lowerCamelCase, `mos_` prefix)
- Methods: max 40 lines; split into helpers if longer
- Docstrings: Google style on Python public functions and classes
- Error handling: never swallow exceptions; structured logs with correlation ID (no PHI values)
- Secrets: AWS Secrets Manager / platform vault in production — **no** literals in committed config
- Orchestration: Claude Agent SDK / ActiveMQ / Step Functions — **no** n8n

## API Standards

- REST JSON; OpenAPI when routes expand beyond health
- JWT and MSS for protected routes when APIs expose data
- Rate limiting at gateway for public endpoints

## Tier 2 Compliance Requirements

- Encrypt data at rest and in transit for any PHI-classification data
- Log access to sensitive analytics with actor, tenant, resource id (never raw PHI in logs)
- Parameterized SQL only; tenant isolation at schema or row level
- Feature IDs in `feature_list.json` map to requirements when QMS links exist

## Git Branch Strategy

- `main`: production-ready only. No direct commits.
- `develop`: integration branch (if used)
- Feature branches: `feature/F###-short-description`
- Agents commit on feature branches and open PRs.

## Known Issues / Current State

- Scaffold only: Trino catalog for Compose lives under `docker/trino/catalog/`. Template with env placeholders: `config/trino-catalog-omop.properties`.
- `/ready` does not yet check PostgreSQL or Trino connectivity.

## Last Updated

2026-03-30 — Harness 2.1 initializer scaffold (Session 0)

## Code Navigation — jCodeMunch (use instead of reading files)

All repos are pre-indexed by a background daemon. Use these MCP tools:

```
list_repos                                             → check indexed repos
search_symbols: { "repo": "<name>", "query": "..." }  → find functions/classes
get_symbol:     { "repo": "<name>", "symbol_id": "..." } → get exact source
get_repo_outline:   { "repo": "<name>" }               → repo structure
get_context_bundle: { "repo": "<name>", "symbol_id": "..." } → symbol + imports
```

Fall back to direct file reads only when editing. Zero cost — uses local Ollama.
