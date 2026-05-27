set -euo pipefail
cd "$(dirname "$0")"

source ../../config/config_RTL

vsim -do tb/top/top_tb.do