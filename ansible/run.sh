#!/bin/bash
set -e

echo "[INFO] Updating inventory from Terraform outputs..."
../scripts/update_inventory.sh

echo "[INFO] Running Kafka cluster provisioning..."
ansible-playbook -i inventory/hosts.ini playbooks/kafka.yml

echo "[INFO] Installing Node Exporter..."
ansible-playbook -i inventory/hosts.ini playbooks/node_exporter.yml

echo "[INFO] Installing JMX Exporter..."
ansible-playbook -i inventory/hosts.ini playbooks/jmx.yml

echo "[DONE] Cluster provisioning completed."
