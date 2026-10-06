import argparse
import concurrent.futures
import statistics
import time
from collections import Counter

import requests


def request_once(url: str, timeout: float):
    started = time.perf_counter()
    try:
        r = requests.get(url, timeout=timeout)
        status = r.status_code
    except requests.RequestException:
        status = 0
    elapsed_ms = (time.perf_counter() - started) * 1000
    return status, elapsed_ms


def percentile(values, p):
    values = sorted(values)
    idx = int(round((len(values) - 1) * p))
    return values[idx]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--requests", type=int, default=200)
    parser.add_argument("--concurrency", type=int, default=50)
    parser.add_argument("--timeout", type=float, default=5.0)
    args = parser.parse_args()

    started = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.concurrency) as pool:
        results = list(pool.map(
            lambda _: request_once(args.url, args.timeout),
            range(args.requests),
        ))
    wall = time.perf_counter() - started

    statuses = Counter(status for status, _ in results)
    latencies = [ms for _, ms in results]
    success = sum(count for status, count in statuses.items() if 200 <= status < 400)

    print("HTTP Load Test")
    print("--------------")
    print(f"URL:          {args.url}")
    print(f"Requests:     {args.requests}")
    print(f"Concurrency:  {args.concurrency}")
    print(f"Successful:   {success}")
    print(f"Failed:       {args.requests - success}")
    print(f"Statuses:     {dict(sorted(statuses.items()))}")
    print(f"Average:      {statistics.mean(latencies):.2f} ms")
    print(f"Median:       {statistics.median(latencies):.2f} ms")
    print(f"P95:          {percentile(latencies, 0.95):.2f} ms")
    print(f"P99:          {percentile(latencies, 0.99):.2f} ms")
    print(f"Throughput:   {args.requests / wall:.2f} req/s")


if __name__ == "__main__":
    main()
