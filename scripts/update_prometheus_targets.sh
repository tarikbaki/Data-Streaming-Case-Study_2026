#!/bin/bash

# Bu script terraform output'lardan ip'leri alip prometheus.yml icine yaziyor

BROKERS=$(terraform -chdir=terraform/envs/prod output -json broker_ips | jq -r '.[]')
CONTROLLERS=$(terraform -chdir=terraform/envs/prod output -json controller_ips | jq -r '.[]')
CONNECT=$(terraform -chdir=terraform/envs/prod output -raw connect_ip)
OBS=$(terraform -chdir=terraform/envs/prod output -raw obs_ip)

PROM_FILE="observability/prometheus/prometheus.yml"

# Temiz bir YAML üretmek için yedek alıp blokları yeniden yazıyorum.
tmpfile=$(mktemp)

awk '
  /AUTO-NODE-EXPORTER-START/ {print; print "  - job_name: \"node_exporter\""; print "    static_configs:"; print "      - targets: ["; for (i in ne_targets) {} next}
  /AUTO-BROKER-JMX-START/ {print; print "  - job_name: \"kafka_broker_jmx\""; print "    static_configs:"; print "      - targets: ["; next}
  /AUTO-CONTROLLER-JMX-START/ {print; print "  - job_name: \"kafka_controller_jmx\""; print "    static_configs:"; print "      - targets: ["; next}
  /AUTO-CONNECT-JMX-START/ {print; print "  - job_name: \"connect_jmx\""; print "    static_configs:"; print "      - targets: ["; next}
  /AUTO-NODE-EXPORTER-END/ {print "        ]"; print; next}
  /AUTO-BROKER-JMX-END/ {print "        ]"; print; next}
  /AUTO-CONTROLLER-JMX-END/ {print "        ]"; print; next}
  /AUTO-CONNECT-JMX-END/ {print "        ]"; print; next}
  {print}
' BROKERS="$BROKERS" CONTROLLERS="$CONTROLLERS" CONNECT="$CONNECT" OBS="$OBS" "$PROM_FILE" > "$tmpfile"

# Targets ekle
add_targets() {
  job_line="$1"
  shift
  for t in "$@"; do
    sed -i '' "/$job_line/{n;n;n; s/]$/          \"$t\",\\n        ]/}" "$tmpfile"
  done
  # son virgülü temizle
  sed -i '' "/$job_line/{n;n;n; s/,\\n        ]/\\n        ]/}" "$tmpfile"
}

node_targets=()
for ip in $BROKERS; do node_targets+=("$ip:9100"); done
for ip in $CONTROLLERS; do node_targets+=("$ip:9100"); done
node_targets+=("$CONNECT:9100" "$OBS:9100")
add_targets "node_exporter" "${node_targets[@]}"

broker_targets=()
for ip in $BROKERS; do broker_targets+=("$ip:5555"); done
add_targets "kafka_broker_jmx" "${broker_targets[@]}"

controller_targets=()
for ip in $CONTROLLERS; do controller_targets+=("$ip:5556"); done
add_targets "kafka_controller_jmx" "${controller_targets[@]}"

add_targets "connect_jmx" "$CONNECT:7777"

mv "$tmpfile" "$PROM_FILE"
echo "Prometheus targets güncellendi: $PROM_FILE"
