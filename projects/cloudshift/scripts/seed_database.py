from decimal import Decimal

from sqlalchemy import select

from app.database import Base, SessionLocal, engine
from app.models import Customer, Product


def main():
    Base.metadata.create_all(bind=engine)

    with SessionLocal() as db:
        existing = db.scalar(select(Customer).limit(1))
        if existing:
            print("Database already contains seed data.")
            return

        customers = [
            Customer(
                name="Aisha Al Khalifa",
                email="aisha@example.com",
                region="BH",
            ),
            Customer(
                name="Omar Al Doseri",
                email="omar@example.com",
                region="SA",
            ),
        ]

        products = [
            Product(
                name="Industrial Sensor",
                sku="SENSOR-001",
                price=Decimal("49.95"),
                stock_quantity=250,
            ),
            Product(
                name="Network Gateway",
                sku="GATEWAY-001",
                price=Decimal("189.00"),
                stock_quantity=80,
            ),
            Product(
                name="Replacement Battery",
                sku="BATTERY-001",
                price=Decimal("24.99"),
                stock_quantity=500,
            ),
        ]

        db.add_all(customers + products)
        db.commit()

    print("Seed data created.")


if __name__ == "__main__":
    main()
