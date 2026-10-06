import logging
import os
import time
from datetime import datetime, timezone
from typing import Any
from uuid import uuid4

from google.cloud import firestore
from google.api_core.exceptions import GoogleAPIError

from app.config import settings
from app.metrics import AUDIT_EVENTS_TOTAL, FIRESTORE_WRITE_DURATION


logger = logging.getLogger("cloudshift.audit")
_client = None


def get_firestore_client():
    global _client
    if not settings.firestore_enabled:
        return None

    if _client is None:
        _client = firestore.Client(
            project=settings.firestore_project_id,
            database=settings.firestore_database,
        )
    return _client


def write_audit_event(
    event_type: str,
    *,
    order_id: int | None = None,
    customer_id: int | None = None,
    outcome: str = "success",
    request_id: str | None = None,
    metadata: dict[str, Any] | None = None,
) -> str | None:
    """Write an audit event without making the primary transaction depend on it."""
    client = get_firestore_client()
    if client is None:
        return None

    event_id = str(uuid4())
    now = datetime.now(timezone.utc)
    document = {
        "event_id": event_id,
        "event_type": event_type,
        "timestamp": now,
        "service": settings.app_name,
        "environment": settings.app_env,
        "outcome": outcome,
        "request_id": request_id,
        "order_id": order_id,
        "customer_id": customer_id,
        "metadata": metadata or {},
    }

    started = time.perf_counter()
    try:
        client.collection(settings.audit_collection).document(event_id).set(document)
        elapsed = time.perf_counter() - started
        FIRESTORE_WRITE_DURATION.observe(elapsed)
        AUDIT_EVENTS_TOTAL.labels(event_type=event_type, outcome=outcome).inc()

        logger.info(
            "audit_event_written",
            extra={
                "event": "audit_event_written",
                "event_type": event_type,
                "audit_event_id": event_id,
                "order_id": order_id,
                "customer_id": customer_id,
                "outcome": outcome,
                "firestore_write_ms": round(elapsed * 1000, 2),
                "request_id": request_id,
            },
        )
        return event_id
    except GoogleAPIError:
        AUDIT_EVENTS_TOTAL.labels(event_type=event_type, outcome="write_failed").inc()
        logger.exception(
            "audit_event_write_failed",
            extra={
                "event": "audit_event_write_failed",
                "event_type": event_type,
                "order_id": order_id,
                "customer_id": customer_id,
                "request_id": request_id,
            },
        )
        return None


def list_recent_events(limit: int = 20) -> list[dict[str, Any]]:
    client = get_firestore_client()
    if client is None:
        return []

    docs = (
        client.collection(settings.audit_collection)
        .order_by("timestamp", direction=firestore.Query.DESCENDING)
        .limit(limit)
        .stream()
    )

    results = []
    for doc in docs:
        data = doc.to_dict()
        if data.get("timestamp") is not None:
            data["timestamp"] = data["timestamp"].isoformat()
        results.append(data)
    return results


def list_order_events(order_id: int, limit: int = 50) -> list[dict[str, Any]]:
    client = get_firestore_client()
    if client is None:
        return []

    docs = (
        client.collection(settings.audit_collection)
        .where("order_id", "==", order_id)
        .limit(limit)
        .stream()
    )

    results = []
    for doc in docs:
        data = doc.to_dict()
        if data.get("timestamp") is not None:
            data["timestamp"] = data["timestamp"].isoformat()
        results.append(data)

    results.sort(key=lambda x: x.get("timestamp", ""), reverse=True)
    return results
