import argparse
import statistics
import time

from sqlalchemy import text

from app.database import SessionLocal


def percentile(values, p):
    values = sorted(values)
    idx = int(round((len(values) - 1) * p))
    return values[idx]


def main():
    parser = argparse.ArgumentParser(
        description="Measure and inspect customer order lookup performance."
    )
    parser.add_argument("--customer-id", type=int, required=True)
    parser.add_argument("--runs", type=int, default=20)
    args = parser.parse_args()

    query = text(
        '''
        SELECT id, customer_id, status, created_at
        FROM orders
        WHERE customer_id = :customer_id
        ORDER BY created_at DESC
        '''
    )

    explain = text(
        '''
        EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
        SELECT id, customer_id, status, created_at
        FROM orders
        WHERE customer_id = :customer_id
        ORDER BY created_at DESC
        '''
    )

    with SessionLocal() as db:
        print("Query Plan")
        print("----------")
        plan_rows = db.execute(
            explain,
            {"customer_id": args.customer_id},
        ).all()

        for row in plan_rows:
            print(row[0])

        latencies = []
        row_count = 0

        for _ in range(args.runs):
            started = time.perf_counter()
            rows = db.execute(
                query,
                {"customer_id": args.customer_id},
            ).all()
            elapsed_ms = (time.perf_counter() - started) * 1000
            latencies.append(elapsed_ms)
            row_count = len(rows)

        print()
        print("Customer Order Query Benchmark")
        print("------------------------------")
        print(f"Customer ID:     {args.customer_id}")
        print(f"Rows returned:   {row_count:,}")
        print(f"Runs:            {args.runs}")
        print(f"Average:         {statistics.mean(latencies):.2f} ms")
        print(f"Median:          {statistics.median(latencies):.2f} ms")
        print(f"P95:             {percentile(latencies, 0.95):.2f} ms")
        print(f"Fastest:         {min(latencies):.2f} ms")
        print(f"Slowest:         {max(latencies):.2f} ms")


if __name__ == "__main__":
    main()
