#!/bin/bash

# Bu script terraform output'lardan ip'leri alip prometheus.yml icine yaziyor

BROKERS=$(terraform -chdir=terraform/envs/prod output -json broker_ips | jq -r '.[]')
CONTROLLERS=$(terraform -chdir=terraform/envs/prod output -json controller_ips | jq -r '.[]')
CONNECT=$(terraform -chdir=terraform/envs/prod output -raw connect_ip)
OBS=$(terraform -chdir=terraform/envs/prod output -raw obs_ip)

PROM_FILE="observability/prometheus/prometheus.yml"

# eski targetlari temizle
sed -i '' '/node_exporter/,/targets/d' $PROM_FILE
sed -i '' '/kafka_jmx/,/targets/d' $PROM_FILE
sed -i '' '/connect_jmx/,/targets/d' $PROM_FILE

# tekrar ekle
cat <<EOF >> $PROM_FILE

  - job_name: 'node_exporter'
    static_configs:
      - targets: [
EOF

for ip in $BROKERS; do
  echo "          \"$ip:9100\"," >> $PROM_FILE
done

for ip in $CONTROLLERS; do
  echo "          \"$ip:9100\"," >> $PROM_FILE
done

echo "          \"$CONNECT:9100\"," >> $PROM_FILE
echo "          \"$OBS:9100\"" >> $PROM_FILE
echo "        ]" >> $PROM_FILE


cat <<EOF >> $PROM_FILE

  - job_name: 'kafka_jmx'
    static_configs:
      - targets: [
EOF

for ip in $BROKERS; do
  echo "          \"$ip:5555\"," >> $PROM_FILE
done

for ip in $CONTROLLERS; do
  echo "          \"$ip:5556\"," >> $PROM_FILE
done

echo "        ]" >> $PROM_FILE


cat <<EOF >> $PROM_FILE

  - job_name: 'connect_jmx'
    static_configs:
      - targets: [
          "$CONNECT:7777"
        ]
EOF
