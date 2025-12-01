#!/bin/bash

# Bu script terraform output'lardan aldığım IP'lerle
# ansible inventory dosyasını sıfırdan yeniden oluşturuyor.
# broker-0..3, controller-0..2, connect ve observability hostlarını
# otomatik olarak hosts.ini içine yazıyor.

INV_FILE="ansible/inventory/hosts.ini"

# Terraform output'lardan IP'leri çekiyorum
BROKERS=$(terraform -chdir=terraform/envs/prod output -json broker_ips | jq -r '.[]')
CONTROLLERS=$(terraform -chdir=terraform/envs/prod output -json controller_ips | jq -r '.[]')
CONNECT=$(terraform -chdir=terraform/envs/prod output -raw connect_ip)
OBS=$(terraform -chdir=terraform/envs/prod output -raw obs_ip)

# hosts.ini dosyasını tamamen sıfırdan oluşturuyorum
cat <<EOF > $INV_FILE
[broker]
EOF

i=0
for ip in $BROKERS; do
  echo "broker-$i ansible_host=$ip" >> $INV_FILE
  i=$((i+1))
done

cat <<EOF >> $INV_FILE

[controller]
EOF

i=0
for ip in $CONTROLLERS; do
  echo "controller-$i ansible_host=$ip" >> $INV_FILE
  i=$((i+1))
done

cat <<EOF >> $INV_FILE

[connect]
connect ansible_host=$CONNECT

[observability]
observability ansible_host=$OBS
EOF

echo "Inventory güncellendi: $INV_FILE"
