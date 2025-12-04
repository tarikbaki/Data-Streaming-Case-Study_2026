#!/bin/bash

# Bu script terraform output'lardan ip'leri alip prometheus.yml icine yaziyor

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TF_DIR="${TF_DIR:-$REPO_ROOT/terraform/envs/vagrant}"
PROM_FILE="$REPO_ROOT/observability/prometheus/prometheus.yml"

BROKERS=$(terraform -chdir="$TF_DIR" output -json broker_ips | jq -r '.[]')
CONTROLLERS=$(terraform -chdir="$TF_DIR" output -json controller_ips | jq -r '.[]')
CONNECT=$(terraform -chdir="$TF_DIR" output -raw connect_ip)
OBS=$(terraform -chdir="$TF_DIR" output -raw obs_ip)

join_lines() {
  local prefix=$1; shift
  for item in "$@"; do
    echo "        - \"${item}\""
  done
}

node_targets=()
for ip in $BROKERS; do node_targets+=("${ip}:9100"); done
for ip in $CONTROLLERS; do node_targets+=("${ip}:9100"); done
node_targets+=("${CONNECT}:9100" "${OBS}:9100")

broker_jmx=()
for ip in $BROKERS; do broker_jmx+=("${ip}:5555"); done

controller_jmx=()
for ip in $CONTROLLERS; do controller_jmx+=("${ip}:5556"); done

connect_jmx=("${CONNECT}:7777" "${CONNECT}:7778")

cat > "$PROM_FILE" <<EOF
# Bu dosyada Prometheus'un tüm scrape ayarlarını tutuyorum.

global:
  scrape_interval: 5s

rule_files:
  - "alerts.yml"

scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets:
$(join_lines "" "${node_targets[@]}")

  - job_name: "kafka_broker_jmx"
    static_configs:
      - targets:
$(join_lines "" "${broker_jmx[@]}")

  - job_name: "kafka_controller_jmx"
    static_configs:
      - targets:
$(join_lines "" "${controller_jmx[@]}")

  - job_name: "connect_jmx"
    static_configs:
      - targets:
$(join_lines "" "${connect_jmx[@]}")
EOF

echo "Prometheus targets güncellendi: $PROM_FILE"
