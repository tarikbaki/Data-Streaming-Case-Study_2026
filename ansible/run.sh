#!/bin/bash
# Bu scripti kendime kolaylık olsun diye yazdım.
# Terraform’dan gelen IP’lerle inventory ve prometheus targetlarını güncelliyor,
# sonra da Kafka cluster + node exporter + jmx exporter + prometheus kurulumlarını sırayla çalıştırıyor.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="${TF_DIR:-$REPO_ROOT/terraform/envs/vagrant}"

cd "$REPO_ROOT"

echo "[INFO] Updating inventory from Terraform outputs ($TF_DIR)..."
TF_DIR="$TF_DIR" "$REPO_ROOT/scripts/update_inventory.sh"

echo "[INFO] Updating Prometheus targets from Terraform outputs..."
TF_DIR="$TF_DIR" "$REPO_ROOT/scripts/update_prometheus_targets.sh"

cd "$REPO_ROOT/ansible"

echo "[INFO] Bootstrap Python/utilities on all nodes..."
ansible-playbook -i inventory/hosts.ini playbooks/bootstrap.yml

echo "[INFO] Generating TLS keystore/truststore (demo self-signed)..."
ansible-playbook -i inventory/hosts.ini playbooks/certs.yml

echo "[INFO] Running Kafka cluster provisioning..."
ansible-playbook -i inventory/hosts.ini playbooks/kafka.yml

echo "[INFO] Installing Node Exporter..."
ansible-playbook -i inventory/hosts.ini playbooks/node_exporter.yml

echo "[INFO] Installing JMX Exporter..."
ansible-playbook -i inventory/hosts.ini playbooks/jmx.yml

echo "[INFO] Installing Prometheus stack on observability node..."
ansible-playbook -i inventory/hosts.ini playbooks/prometheus.yml

echo "[DONE] Cluster provisioning completed."
