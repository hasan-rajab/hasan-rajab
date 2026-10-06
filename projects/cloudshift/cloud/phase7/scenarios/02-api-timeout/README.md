# Scenario 02 — API Timeout
Expected signals: API remains healthy, quote endpoint returns 504, timeout metric rises, Firestore records SHIPPING_TIMEOUT, JSON logs show timeout.
