# MedinovAI Production Dockerfile — Python FastAPI Service
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN addgroup --system --gid 1001 medinovai && \
    adduser --system --uid 1001 --ingroup medinovai medinovai

WORKDIR /app

# ── Install dependencies ────────────────────────────────────────────────────
# setuptools required for pkg_resources (opentelemetry, many older packages)
COPY requirements*.txt ./
RUN pip install --upgrade pip setuptools wheel && \
    (pip install -r requirements.txt 2>/dev/null || \
     pip install fastapi uvicorn[standard] httpx prometheus-client pydantic)

# ── Copy source ─────────────────────────────────────────────────────────────
COPY --chown=medinovai:medinovai . .

USER medinovai

EXPOSE ${PORT:-8080}

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD python3 -c "import urllib.request,os; urllib.request.urlopen('http://127.0.0.1:'+os.environ.get('PORT','8080')+'/health')" || exit 1

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 2"]
