from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, model_validator


class CustomerOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: str
    region: str


class ProductOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    sku: str
    price: Decimal
    stock_quantity: int


class OrderItemCreate(BaseModel):
    product_id: int
    quantity: int = Field(gt=0)


class OrderCreate(BaseModel):
    customer_id: int
    items: list[OrderItemCreate] = Field(min_length=1)

    @model_validator(mode="after")
    def require_unique_product_ids(self):
        product_ids = [item.product_id for item in self.items]
        if len(product_ids) != len(set(product_ids)):
            raise ValueError("each product_id may appear only once per order")
        return self


class OrderItemOut(BaseModel):
    product_id: int
    quantity: int
    unit_price: Decimal


class OrderOut(BaseModel):
    id: int
    customer_id: int
    status: str
    created_at: datetime
    total: Decimal
    items: list[OrderItemOut]
