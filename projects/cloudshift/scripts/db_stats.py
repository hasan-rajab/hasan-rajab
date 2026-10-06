from sqlalchemy import text

from app.database import SessionLocal


def main():
    statements = {
        "customers": "SELECT COUNT(*) FROM customers",
        "products": "SELECT COUNT(*) FROM products",
        "orders": "SELECT COUNT(*) FROM orders",
        "order_items": "SELECT COUNT(*) FROM order_items",
    }

    with SessionLocal() as db:
        print("CloudShift Database Statistics")
        print("------------------------------")
        for label, sql in statements.items():
            count = db.execute(text(sql)).scalar_one()
            print(f"{label:<12} {count:>12,}")

        size = db.execute(
            text("SELECT pg_size_pretty(pg_database_size(current_database()))")
        ).scalar_one()
        print(f"{'db_size':<12} {size:>12}")


if __name__ == "__main__":
    main()
