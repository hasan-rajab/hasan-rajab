import os
import time

from fastapi import FastAPI, Header, HTTPException

app = FastAPI(title="Mock Shipping Service", version="1.0.0")


def delay_seconds() -> float:
    return float(os.getenv("SHIPPING_DELAY_SECONDS", "0.15"))


def required_token() -> str:
    return os.getenv("SHIPPING_REQUIRED_TOKEN", "cloudshift-demo-token")


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "delay_seconds": delay_seconds(),
        "authentication": "bearer-token-required",
    }


@app.get("/quote/{order_id}")
def quote(order_id: int, authorization: str | None = Header(default=None)):
    expected = f"Bearer {required_token()}"
    if authorization != expected:
        raise HTTPException(status_code=401, detail="Invalid shipping API token")

    delay = delay_seconds()
    time.sleep(delay)
    return {
        "order_id": order_id,
        "carrier": "GulfExpress",
        "currency": "BHD",
        "shipping_cost": 2.500,
        "downstream_delay_seconds": delay,
    }
