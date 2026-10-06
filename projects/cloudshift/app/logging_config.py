import json
import logging
import sys
from datetime import datetime, timezone

from app.config import settings


STANDARD_ATTRS = {
    "name", "msg", "args", "levelname", "levelno", "pathname", "filename",
    "module", "exc_info", "exc_text", "stack_info", "lineno", "funcName",
    "created", "msecs", "relativeCreated", "thread", "threadName",
    "processName", "process", "taskName"
}


class CloudJsonFormatter(logging.Formatter):
    """Emit one JSON object per line.

    Cloud Logging recognizes structured JSON payloads when containers write
    serialized JSON to stdout/stderr. We intentionally use Cloud Logging field
    names such as severity and message where useful.
    """

    def format(self, record: logging.LogRecord) -> str:
        payload = {
            "severity": record.levelname,
            "message": record.getMessage(),
            "timestamp": datetime.fromtimestamp(
                record.created, tz=timezone.utc
            ).isoformat(),
            "service": settings.app_name,
            "environment": settings.app_env,
            "logger": record.name,
        }

        for key, value in record.__dict__.items():
            if key not in STANDARD_ATTRS and not key.startswith("_"):
                try:
                    json.dumps(value)
                    payload[key] = value
                except (TypeError, ValueError):
                    payload[key] = str(value)

        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)

        return json.dumps(payload, separators=(",", ":"), ensure_ascii=False)


def configure_logging() -> None:
    root = logging.getLogger()
    root.handlers.clear()
    root.setLevel(getattr(logging, settings.log_level.upper(), logging.INFO))

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(CloudJsonFormatter())
    root.addHandler(handler)
