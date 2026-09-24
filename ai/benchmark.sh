#!/bin/bash

set -euo pipefail

cycles="${1:-20}"
binary="${CMDTAB_BENCHMARK_BINARY:-DerivedData/Build/Products/Debug/CmdTab.app/Contents/MacOS/CmdTab}"
output="${CMDTAB_BENCHMARK_OUTPUT:-/tmp/cmdtab-benchmark-$$.json}"

if [ ! -x "$binary" ]; then
    echo "Benchmark binary not found: $binary"
    echo "Build it first with the command in ai/build.sh."
    exit 1
fi

"$binary" --logs=error --benchmark showUi "$cycles" --benchmark-output "$output"
if [ ! -f "$output" ]; then
    echo "Benchmark produced no report; verify that this build has Accessibility permission."
    exit 1
fi

p50=$(/usr/bin/plutil -extract p50Ms raw -o - "$output")
p95=$(/usr/bin/plutil -extract p95Ms raw -o - "$output")
maximum=$(/usr/bin/plutil -extract maxMs raw -o - "$output")
echo "Benchmark report: $output"
echo "showUi: p50=${p50}ms p95=${p95}ms max=${maximum}ms"

if [ -n "${CMDTAB_BENCHMARK_P95_BUDGET_MS:-}" ]; then
    /usr/bin/awk -v actual="$p95" -v budget="$CMDTAB_BENCHMARK_P95_BUDGET_MS" 'BEGIN { if (actual > budget) { printf "Regression: p95 %.3fms exceeds %.3fms budget\n", actual, budget; exit 1 } }'
fi
