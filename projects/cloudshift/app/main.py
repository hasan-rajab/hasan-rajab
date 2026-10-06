import logging
import time
from uuid import uuid4
from contextlib import asynccontextmanager
from decimal import Decimal

from fastapi import Depends, FastAPI, HTTPException, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from sqlalchemy import select, text
from sqlalchemy.orm import Session
from sqlalchemy.exc import TimeoutError as SQLAlchemyTimeoutError

import requests

from app.config import settings
from app.logging_config import configure_logging
from app.audit import list_order_events, list_recent_events, write_audit_event
from app.database import Base, engine, get_db
from app.metrics import (
    DEPENDENCY_DURATION,
    DEPENDENCY_REQUESTS_TOTAL,
    ERRORS_TOTAL,
    ORDERS_CREATED,
    REQUEST_DURATION,
    REQUESTS_TOTAL,
)
from app.models import Customer, Order, OrderItem, Product
from app.schemas import CustomerOut, OrderCreate, OrderItemOut, OrderOut, ProductOut


configure_logging()
logger = logging.getLogger("cloudshift")


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    logger.info("database tables verified")
    yield


app = FastAPI(
    title="CloudShift Legacy API",
    version="1.0.0",
    description="Inventory and order-management API for the CloudShift migration lab.",
    lifespan=lifespan,
)

cors_origins = [
    origin.strip()
    for origin in settings.cors_origins.split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def observability_middleware(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID") or str(uuid4())
    request.state.request_id = request_id

    start = time.perf_counter()
    response = None

    try:
        response = await call_next(request)
        return response
    finally:
        duration = time.perf_counter() - start
        status_code = response.status_code if response else 500
        status = str(status_code)

        REQUESTS_TOTAL.labels(request.method, request.url.path, status).inc()
        REQUEST_DURATION.labels(request.method, request.url.path).observe(duration)

        if status_code >= 400:
            ERRORS_TOTAL.labels(status_class=f"{status_code // 100}xx").inc()

        if response is not None:
            response.headers["X-Request-ID"] = request_id

        logger.info(
            "http_request_completed",
            extra={
                "event": "http_request_completed",
                "request_id": request_id,
                "http_method": request.method,
                "http_path": request.url.path,
                "http_status": status_code,
                "latency_ms": round(duration * 1000, 2),
            },
        )


@app.get("/")
def root():
    return {
        "service": settings.app_name,
        "environment": settings.app_env,
        "message": "CloudShift API is running",
        "docs": "/docs",
    }


@app.get("/health")
def health(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        return {
            "status": "healthy",
            "database": "connected",
            "version": app.version,
            "environment": settings.app_env,
        }
    except Exception:
        logger.exception("database health check failed")
        raise HTTPException(
            status_code=503,
            detail={
                "status": "unhealthy",
                "database": "unreachable",
            },
        )


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/customers/{customer_id}", response_model=CustomerOut)
def get_customer(customer_id: int, db: Session = Depends(get_db)):
    customer = db.get(Customer, customer_id)
    if customer is None:
        raise HTTPException(status_code=404, detail="Customer not found")
    return customer


@app.get("/products", response_model=list[ProductOut])
def list_products(db: Session = Depends(get_db)):
    return db.scalars(select(Product).order_by(Product.id)).all()


@app.get("/products/{product_id}", response_model=ProductOut)
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = db.get(Product, product_id)
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


@app.post("/orders", response_model=OrderOut, status_code=201)
def create_order(payload: OrderCreate, db: Session = Depends(get_db)):
    customer = db.get(Customer, payload.customer_id)
    if customer is None:
        raise HTTPException(status_code=404, detail="Customer not found")

    order = Order(customer_id=payload.customer_id, status="created")
    db.add(order)
    db.flush()

    response_items: list[OrderItemOut] = []
    total = Decimal("0.00")

    for requested_item in payload.items:
        product = db.get(Product, requested_item.product_id)
        if product is None:
            db.rollback()
            raise HTTPException(
                status_code=404,
                detail=f"Product {requested_item.product_id} not found",
            )

        if product.stock_quantity < requested_item.quantity:
            db.rollback()
            raise HTTPException(
                status_code=409,
                detail=f"Insufficient stock for product {product.id}",
            )

        product.stock_quantity -= requested_item.quantity
        line_total = product.price * requested_item.quantity
        total += line_total

        item = OrderItem(
            order_id=order.id,
            product_id=product.id,
            quantity=requested_item.quantity,
            unit_price=product.price,
        )
        db.add(item)

        response_items.append(
            OrderItemOut(
                product_id=product.id,
                quantity=requested_item.quantity,
                unit_price=product.price,
            )
        )

    db.commit()
    db.refresh(order)
    ORDERS_CREATED.inc()

    write_audit_event(
        "ORDER_CREATED",
        order_id=order.id,
        customer_id=order.customer_id,
        request_id=None,
        metadata={
            "item_count": len(response_items),
            "total": str(total),
        },
    )

    return OrderOut(
        id=order.id,
        customer_id=order.customer_id,
        status=order.status,
        created_at=order.created_at,
        total=total,
        items=response_items,
    )


@app.get("/orders/{order_id}", response_model=OrderOut)
def get_order(order_id: int, db: Session = Depends(get_db)):
    order = db.get(Order, order_id)
    if order is None:
        if settings.scenario_bad_http_status:
            logger.warning("bad_http_status_mode order_id=%s returning=200 expected=404", order_id)
            return JSONResponse(
                status_code=200,
                content={"error": "Order not found", "order_id": order_id},
            )
        raise HTTPException(status_code=404, detail="Order not found")

    items = [
        OrderItemOut(
            product_id=item.product_id,
            quantity=item.quantity,
            unit_price=item.unit_price,
        )
        for item in order.items
    ]

    total = sum(
        (item.unit_price * item.quantity for item in order.items),
        start=Decimal("0.00"),
    )

    return OrderOut(
        id=order.id,
        customer_id=order.customer_id,
        status=order.status,
        created_at=order.created_at,
        total=total,
        items=items,
    )


@app.get("/customers/{customer_id}/orders", response_model=list[OrderOut])
def get_customer_orders(customer_id: int, db: Session = Depends(get_db)):
    customer = db.get(Customer, customer_id)
    if customer is None:
        raise HTTPException(status_code=404, detail="Customer not found")

    orders = db.scalars(
        select(Order).where(Order.customer_id == customer_id).order_by(Order.created_at.desc())
    ).all()

    result = []
    for order in orders:
        items = [
            OrderItemOut(
                product_id=item.product_id,
                quantity=item.quantity,
                unit_price=item.unit_price,
            )
            for item in order.items
        ]
        total = sum(
            (item.unit_price * item.quantity for item in order.items),
            start=Decimal("0.00"),
        )
        result.append(
            OrderOut(
                id=order.id,
                customer_id=order.customer_id,
                status=order.status,
                created_at=order.created_at,
                total=total,
                items=items,
            )
        )

    return result

@app.get("/orders/{order_id}/shipping-quote")
def get_shipping_quote(order_id: int, db: Session = Depends(get_db)):
    order = db.get(Order, order_id)
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    url = f"{settings.shipping_base_url}/quote/{order_id}"
    started = time.perf_counter()

    try:
        response = requests.get(
            url,
            headers={"Authorization": f"Bearer {settings.shipping_api_token}"},
            timeout=settings.shipping_timeout_seconds,
        )

        if response.status_code in (401, 403):
            elapsed = time.perf_counter() - started
            DEPENDENCY_REQUESTS_TOTAL.labels(
                dependency="shipping", outcome="auth_failure"
            ).inc()
            DEPENDENCY_DURATION.labels(dependency="shipping").observe(elapsed)
            write_audit_event(
                "SHIPPING_AUTH_FAILURE",
                order_id=order_id,
                outcome="failure",
                metadata={"upstream_status": response.status_code},
            )
            logger.error(
                "shipping_upstream_auth_failure order_id=%s dependency=%s status=%s elapsed_seconds=%.3f",
                order_id,
                settings.shipping_base_url,
                response.status_code,
                elapsed,
            )
            raise HTTPException(
                status_code=502,
                detail=f"Shipping service authentication failed ({response.status_code})",
            )

        response.raise_for_status()

    except requests.Timeout:
        elapsed = time.perf_counter() - started
        DEPENDENCY_REQUESTS_TOTAL.labels(
            dependency="shipping", outcome="timeout"
        ).inc()
        DEPENDENCY_DURATION.labels(dependency="shipping").observe(elapsed)
        write_audit_event(
            "SHIPPING_TIMEOUT",
            order_id=order_id,
            outcome="failure",
            metadata={"timeout_seconds": settings.shipping_timeout_seconds},
        )
        logger.error(
            "shipping_quote_timeout order_id=%s dependency=%s timeout_seconds=%s elapsed_seconds=%.3f",
            order_id,
            settings.shipping_base_url,
            settings.shipping_timeout_seconds,
            elapsed,
        )
        raise HTTPException(status_code=504, detail="Shipping service timed out")
    except requests.RequestException as exc:
        elapsed = time.perf_counter() - started
        DEPENDENCY_REQUESTS_TOTAL.labels(
            dependency="shipping", outcome="request_failure"
        ).inc()
        DEPENDENCY_DURATION.labels(dependency="shipping").observe(elapsed)
        write_audit_event(
            "SHIPPING_REQUEST_FAILURE",
            order_id=order_id,
            outcome="failure",
            metadata={"error": exc.__class__.__name__},
        )
        logger.error(
            "shipping_quote_failure order_id=%s dependency=%s elapsed_seconds=%.3f error=%s",
            order_id,
            settings.shipping_base_url,
            elapsed,
            exc.__class__.__name__,
        )
        raise HTTPException(status_code=502, detail="Shipping service request failed")

    elapsed = time.perf_counter() - started
    DEPENDENCY_REQUESTS_TOTAL.labels(
        dependency="shipping", outcome="success"
    ).inc()
    DEPENDENCY_DURATION.labels(dependency="shipping").observe(elapsed)
    write_audit_event(
        "SHIPPING_QUOTE_SUCCEEDED",
        order_id=order_id,
        outcome="success",
        metadata={"latency_ms": round(elapsed * 1000, 2)},
    )
    logger.info(
        "shipping_quote_success",
        extra={
            "event": "shipping_quote_success",
            "order_id": order_id,
            "dependency": "shipping",
            "latency_ms": round(elapsed * 1000, 2),
        },
    )
    payload = response.json()
    payload["cloudshift_dependency_latency_ms"] = round(elapsed * 1000, 2)
    return payload




@app.get("/audit-events")
def get_recent_audit_events(limit: int = 20):
    if not settings.firestore_enabled:
        raise HTTPException(status_code=503, detail="Firestore audit store is disabled")
    limit = max(1, min(limit, 100))
    return {
        "count": len(events := list_recent_events(limit)),
        "events": events,
    }


@app.get("/orders/{order_id}/audit-events")
def get_order_audit_events(order_id: int, limit: int = 50):
    if not settings.firestore_enabled:
        raise HTTPException(status_code=503, detail="Firestore audit store is disabled")
    limit = max(1, min(limit, 100))
    events = list_order_events(order_id, limit)
    return {"order_id": order_id, "count": len(events), "events": events}

@app.get("/diagnostics/db-work")
def database_work(db: Session = Depends(get_db)):
    try:
        started = time.perf_counter()
        db.execute(
            text("SELECT pg_sleep(:delay)"),
            {"delay": settings.db_test_delay_seconds},
        )
        elapsed = time.perf_counter() - started
        return {
            "status": "ok",
            "db_delay_seconds": settings.db_test_delay_seconds,
            "elapsed_ms": round(elapsed * 1000, 2),
        }
    except SQLAlchemyTimeoutError:
        logger.error(
            "db_pool_timeout pool_size=%s max_overflow=%s pool_timeout=%s",
            settings.db_pool_size,
            settings.db_max_overflow,
            settings.db_pool_timeout,
        )
        raise HTTPException(status_code=503, detail="Database connection pool exhausted")
