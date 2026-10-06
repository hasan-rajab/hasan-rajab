from prometheus_client import Counter, Histogram

REQUESTS_TOTAL = Counter(
    "cloudshift_requests_total",
    "Total API requests",
    ["method", "path", "status"],
)

ORDERS_CREATED = Counter(
    "cloudshift_orders_created_total",
    "Total orders created",
)

REQUEST_DURATION = Histogram(
    "cloudshift_request_duration_seconds",
    "API request duration in seconds",
    ["method", "path"],
)


ERRORS_TOTAL = Counter(
    "cloudshift_errors_total",
    "Total CloudShift HTTP errors",
    ["status_class"],
)

DEPENDENCY_REQUESTS_TOTAL = Counter(
    "cloudshift_dependency_requests_total",
    "Total downstream dependency requests",
    ["dependency", "outcome"],
)

DEPENDENCY_DURATION = Histogram(
    "cloudshift_dependency_duration_seconds",
    "Downstream dependency request duration",
    ["dependency"],
)

AUDIT_EVENTS_TOTAL = Counter(
    "cloudshift_audit_events_total",
    "Total Firestore audit event write attempts",
    ["event_type", "outcome"],
)

FIRESTORE_WRITE_DURATION = Histogram(
    "cloudshift_firestore_write_duration_seconds",
    "Firestore audit event write duration",
)
