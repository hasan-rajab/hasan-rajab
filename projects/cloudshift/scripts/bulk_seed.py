import argparse
import random
from datetime import datetime, timedelta
from decimal import Decimal

from sqlalchemy import insert, select

from app.database import SessionLocal
from app.models import Customer, Order, OrderItem, Product


def batched(iterable, batch_size):
    batch = []
    for item in iterable:
        batch.append(item)
        if len(batch) >= batch_size:
            yield batch
            batch = []
    if batch:
        yield batch


def main():
    parser = argparse.ArgumentParser(
        description="Generate a realistic large legacy dataset for SQL performance testing."
    )
    parser.add_argument("--customers", type=int, default=500)
    parser.add_argument("--orders", type=int, default=100000)
    parser.add_argument("--batch-size", type=int, default=5000)
    args = parser.parse_args()

    random.seed(42)

    with SessionLocal() as db:
        products = db.scalars(select(Product).order_by(Product.id)).all()
        if not products:
            raise SystemExit(
                "No products found. Run: python -m scripts.seed_database"
            )

        existing_generated = db.scalar(
            select(Customer).where(Customer.email == "loaduser1@example.com")
        )
        if existing_generated:
            raise SystemExit(
                "Bulk dataset already appears to exist. "
                "Use 'docker compose down -v' only if you intentionally want a clean reset."
            )

        print(f"Creating {args.customers} load-test customers...")
        customer_rows = [
            {
                "name": f"Load User {i}",
                "email": f"loaduser{i}@example.com",
                "region": "BH" if i % 2 else "SA",
            }
            for i in range(1, args.customers + 1)
        ]

        generated_ids = []
        for batch in batched(customer_rows, args.batch_size):
            result = db.execute(
                insert(Customer).returning(Customer.id),
                batch,
            )
            generated_ids.extend(result.scalars().all())
        db.commit()

        # Make one "heavy" customer own a large share of orders, which gives
        # us a meaningful customer-specific lookup to investigate.
        heavy_customer_id = generated_ids[0]
        other_customer_ids = generated_ids[1:]

        print(f"Creating {args.orders:,} orders...")
        created_order_ids = []
        now = datetime.utcnow()

        order_rows = []
        for i in range(args.orders):
            if i < args.orders // 4:
                customer_id = heavy_customer_id
            else:
                customer_id = random.choice(other_customer_ids)

            order_rows.append(
                {
                    "customer_id": customer_id,
                    "status": random.choice(["created", "processing", "shipped"]),
                    "created_at": now - timedelta(minutes=random.randint(0, 525600)),
                }
            )

            if len(order_rows) >= args.batch_size:
                result = db.execute(
                    insert(Order).returning(Order.id),
                    order_rows,
                )
                created_order_ids.extend(result.scalars().all())
                db.commit()
                order_rows = []

        if order_rows:
            result = db.execute(
                insert(Order).returning(Order.id),
                order_rows,
            )
            created_order_ids.extend(result.scalars().all())
            db.commit()

        print("Creating order items...")
        product_info = [(p.id, Decimal(p.price)) for p in products]
        item_rows = []

        for order_id in created_order_ids:
            product_id, price = random.choice(product_info)
            item_rows.append(
                {
                    "order_id": order_id,
                    "product_id": product_id,
                    "quantity": random.randint(1, 5),
                    "unit_price": price,
                }
            )

            if len(item_rows) >= args.batch_size:
                db.execute(insert(OrderItem), item_rows)
                db.commit()
                item_rows = []

        if item_rows:
            db.execute(insert(OrderItem), item_rows)
            db.commit()

        print()
        print("Bulk dataset created.")
        print(f"Generated customers: {len(generated_ids):,}")
        print(f"Generated orders:    {len(created_order_ids):,}")
        print(f"Heavy customer ID:   {heavy_customer_id}")
        print()
        print("Use this customer for SQL performance testing:")
        print(f"  {heavy_customer_id}")


if __name__ == "__main__":
    main()
