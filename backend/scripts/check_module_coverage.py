from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent


def _normalize_path(path_str: str) -> str | None:
    try:
        relative_path = Path(path_str).resolve().relative_to(PROJECT_ROOT)
    except ValueError:
        return None
    return relative_path.as_posix()


def load_thresholds(thresholds_path: Path) -> dict[str, float]:
    try:
        raw_thresholds = json.loads(thresholds_path.read_text())
    except FileNotFoundError as exc:
        raise SystemExit(f"Threshold file not found: {thresholds_path}") from exc

    thresholds: dict[str, float] = {}
    for file_path, value in raw_thresholds.items():
        normalized = _normalize_path(PROJECT_ROOT / file_path)
        if normalized is None:
            normalized = Path(file_path).as_posix()
        thresholds[normalized] = float(value)
    return thresholds


def load_coverage(report_path: Path) -> dict[str, float]:
    try:
        coverage_data = json.loads(report_path.read_text())
    except FileNotFoundError as exc:
        raise SystemExit(f"Coverage report missing: {report_path}") from exc

    files = coverage_data.get("files", {})
    coverage_by_file: dict[str, float] = {}
    for file_path, stats in files.items():
        normalized = _normalize_path(file_path)
        if normalized is None:
            continue
        summary = stats.get("summary", {})
        percent = summary.get("percent_covered")
        if percent is not None:
            coverage_by_file[normalized] = float(percent)
    return coverage_by_file


def enforce_thresholds(
    coverage_by_file: dict[str, float], thresholds: dict[str, float]
) -> list[str]:
    failures: list[str] = []
    for file_path, minimum in thresholds.items():
        covered = coverage_by_file.get(file_path)
        if covered is None or covered < minimum:
            failures.append(
                f"{file_path} covered {covered or 0:.1f}% (minimum required {minimum:.1f}%)"
            )
    return failures


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate per-module coverage thresholds."
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=Path("coverage.json"),
        help="Path to coverage JSON report (default: coverage.json)",
    )
    parser.add_argument(
        "--thresholds",
        type=Path,
        default=Path("tests/coverage-thresholds.json"),
        help="JSON file with module -> minimum coverage mapping",
    )
    args = parser.parse_args()

    coverage_by_file = load_coverage(args.report)
    thresholds = load_thresholds(args.thresholds)
    failures = enforce_thresholds(coverage_by_file, thresholds)

    if failures:
        print("Coverage thresholds not met:")
        for failure in failures:
            print(f" - {failure}")
        return 1

    print("All module coverage thresholds satisfied.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

