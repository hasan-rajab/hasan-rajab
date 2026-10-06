import argparse
import concurrent.futures
import statistics
import time

import requests


def request_once(base_url: str, timeout: float):
    start = time.perf_counter()
    try:
        response = requests.get(f"{base_url}/products", timeout=timeout)
        ok = 200 <= response.status_code < 400
    except requests.RequestException:
        ok = False
    elapsed_ms = (time.perf_counter() - start) * 1000
    return ok, elapsed_ms


def percentile(values, p):
    values = sorted(values)
    idx = int(round((len(values) - 1) * p))
    return values[idx]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://localhost:8000")
    parser.add_argument("--requests", type=int, default=500)
    parser.add_argument("--concurrency", type=int, default=20)
    parser.add_argument("--timeout", type=float, default=5.0)
    args = parser.parse_args()

    started = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.concurrency) as pool:
        futures = [
            pool.submit(request_once, args.url, args.timeout)
            for _ in range(args.requests)
        ]
        results = [f.result() for f in futures]

    wall_time = time.perf_counter() - started
    latencies = [elapsed for _, elapsed in results]
    failures = sum(1 for ok, _ in results if not ok)

    print("\nCloudShift Local Baseline")
    print("-------------------------")
    print(f"Requests:       {args.requests}")
    print(f"Concurrency:    {args.concurrency}")
    print(f"Successful:     {args.requests - failures}")
    print(f"Failed:         {failures}")
    print(f"Error rate:     {(failures / args.requests) * 100:.2f}%")
    print(f"Average:        {statistics.mean(latencies):.2f} ms")
    print(f"Median:         {statistics.median(latencies):.2f} ms")
    print(f"P95:            {percentile(latencies, 0.95):.2f} ms")
    print(f"P99:            {percentile(latencies, 0.99):.2f} ms")
    print(f"Wall time:      {wall_time:.2f} s")
    print(f"Throughput:     {args.requests / wall_time:.2f} req/s")


if __name__ == "__main__":
    main()
