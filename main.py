"""MedinovAI OMOP Lakehouse API — health and readiness probes."""

from datetime import datetime, timezone
import os

from fastapi import FastAPI

E_SERVICE_NAME = "medinovai-omop-lakehouse"
mos_serviceName = os.getenv("SERVICE_NAME", E_SERVICE_NAME)
mos_registryUrl = os.getenv(
    "REGISTRY_URL", "http://medinovai-registry.medinovai:8000"
)
mos_port = os.getenv("PORT", "8000")

app = FastAPI(title=mos_serviceName, version="0.1.0")


@app.get("/health")
async def health() -> dict[str, str | bool]:
    """Liveness probe for orchestrators."""
    return {
        "status": "healthy",
        "service": mos_serviceName,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "registry": mos_registryUrl,
        "phi_safe": True,
    }


@app.get("/ready")
async def ready() -> dict[str, str]:
    """Readiness probe; extend with DB/Trino checks when wired."""
    return {"status": "ready", "service": mos_serviceName}


@app.get("/")
async def root() -> dict[str, str]:
    """Root metadata."""
    return {
        "service": mos_serviceName,
        "status": "operational",
        "version": "0.1.0",
        "port": mos_port,
    }
