#!/bin/sh
set -eu

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
# Force project root to Zigbee (some environments resolve to filesystem root)
ROOT_DIR="$ROOT_DIR/Zigbee"
cd "$ROOT_DIR"

source config/config_RTL

RAW_TOP_DIR="coverage/raw/top"
mkdir -p "$RAW_TOP_DIR"

echo "Running top TB with coverage..."
vsim -c -do tb/top/top_tb_cov.do

if [ ! -f "$RAW_TOP_DIR/top.ucdb" ]; then
    echo "ERROR: UCDB not generated at $RAW_TOP_DIR/top.ucdb"
    exit 1
fi

echo "Generating raw coverage reports..."
vcover report -summary -output "$RAW_TOP_DIR/vcover_summary.txt" "$RAW_TOP_DIR/top.ucdb"
vcover report -byfile -details -output "$RAW_TOP_DIR/vcover_byfile.txt" "$RAW_TOP_DIR/top.ucdb"
vcover report -html -output "$RAW_TOP_DIR/html" "$RAW_TOP_DIR/top.ucdb"

PYTHON_BIN=${PYTHON_BIN:-python3}
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    PYTHON_BIN=python
fi

"$PYTHON_BIN" coverage/parse_vcover_byfile.py \
    --byfile "$RAW_TOP_DIR/vcover_byfile.txt" \
    --summary "$RAW_TOP_DIR/vcover_summary.txt" \
    --outdir "coverage"

echo "Done. Global report: coverage/coverage_summary.txt and coverage/coverage_summary.csv"
