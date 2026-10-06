import argparse
import subprocess
import sys


def run(cmd):
    print("$ " + " ".join(cmd))
    result = subprocess.run(cmd)
    if result.returncode != 0:
        raise SystemExit(result.returncode)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--customer-id", type=int, default=3)
    parser.add_argument("--runs", type=int, default=20)
    args = parser.parse_args()

    run([
        sys.executable,
        "-m",
        "scripts.analyze_customer_orders",
        "--customer-id",
        str(args.customer_id),
        "--runs",
        str(args.runs),
    ])


if __name__ == "__main__":
    main()
