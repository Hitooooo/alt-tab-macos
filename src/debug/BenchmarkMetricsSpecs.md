# BenchmarkMetrics — Specs

## Summary

`BenchmarkMetrics` stores per-summon phase timings and produces deterministic nearest-rank latency
statistics plus a JSON-serializable report for local profiling and automated regression checks.

## Test scenarios

- **testReportCalculatesNearestRankPercentiles** — unsorted samples produce the expected P50, P95, and maximum.
- **testReportHandlesNoSamples** — an empty run reports zero instead of failing.
- **testReportRoundTripsThroughJson** — an encoded report decodes without losing samples or summary values.
