#!/bin/bash
# Bu scripti kendime kolaylık olsun diye yazdım.
# Terraform’dan gelen IP’lerle inventory’i güncelliyor, sonra da
# Kafka cluster + node exporter + jmx exporter kurulumlarını sırayla çalıştırıyorum.
# Yani tek komutla tüm provisioning bitsin diye düşündüm.

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
