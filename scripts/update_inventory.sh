#!/bin/bash

# Bu script terraform output'lardan aldığım IP'lerle
# ansible inventory dosyasını sıfırdan yeniden oluşturuyor.
# Vagrant lokal ortamı varsayılan; TF_DIR ile prod'a da yönlendirilebilir.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TF_DIR="${TF_DIR:-$REPO_ROOT/terraform/envs/vagrant}"
INV_FILE="$REPO_ROOT/ansible/inventory/hosts.ini"

if [ ! -d "$TF_DIR" ]; then
  echo "[ERR] TF_DIR bulunamadı: $TF_DIR" >&2
  exit 1
fi

# Terraform output'lardan IP'leri çekiyorum
BROKERS=$(terraform -chdir="$TF_DIR" output -json broker_ips | jq -r '.[]')
CONTROLLERS=$(terraform -chdir="$TF_DIR" output -json controller_ips | jq -r '.[]')
CONNECT=$(terraform -chdir="$TF_DIR" output -raw connect_ip)
OBS=$(terraform -chdir="$TF_DIR" output -raw obs_ip)

# hosts.ini dosyasını tamamen sıfırdan oluşturuyorum
cat <<EOF > "$INV_FILE"
[brokers]
EOF

i=0
for ip in $BROKERS; do
  az="vgt-a"
  if [ $((i % 2)) -eq 1 ]; then az="vgt-b"; fi
  echo "broker-$i ansible_host=$ip availability_zone=${az} ansible_user=vagrant ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key" >> "$INV_FILE"
  i=$((i+1))
done

cat <<EOF >> "$INV_FILE"

[controllers]
EOF

i=0
for ip in $CONTROLLERS; do
  az="vgt-a"
  if [ $i -eq 1 ]; then az="vgt-b"; fi
  if [ $i -eq 2 ]; then az="vgt-c"; fi
  echo "controller-$i ansible_host=$ip availability_zone=${az} ansible_user=vagrant ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key" >> "$INV_FILE"
  i=$((i+1))
done

cat <<EOF >> "$INV_FILE"

[connect]
connect ansible_host=$CONNECT ansible_user=vagrant ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key

[observability]
observability ansible_host=$OBS ansible_user=vagrant ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key
EOF

echo "Inventory güncellendi: $INV_FILE (TF_DIR=$TF_DIR)"
