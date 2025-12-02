#!/bin/bash

# Bu script terraform output'lardan ip'leri alip prometheus.yml icine yaziyor

BROKERS=$(terraform -chdir=terraform/envs/prod output -json broker_ips | jq -r '.[]')
CONTROLLERS=$(terraform -chdir=terraform/envs/prod output -json controller_ips | jq -r '.[]')
CONNECT=$(terraform -chdir=terraform/envs/prod output -raw connect_ip)
OBS=$(terraform -chdir=terraform/envs/prod output -raw obs_ip)

PROM_FILE="observability/prometheus/prometheus.yml"

# Python ile blokları dolduruyorum; macOS/Linux farkı yok.
python - "$PROM_FILE" <<'PY'
import sys, yaml, os

brokers = os.environ.get("BROKERS", "").split()
controllers = os.environ.get("CONTROLLERS", "").split()
connect = os.environ.get("CONNECT", "")
obs = os.environ.get("OBS", "")

path = sys.argv[1]
with open(path) as f:
    data = yaml.safe_load(f)

def set_job(name, targets):
    data.setdefault("scrape_configs", [])
    job = {"job_name": name, "static_configs": [{"targets": targets}]}
    # önce var olanı temizle
    data["scrape_configs"] = [j for j in data["scrape_configs"] if j.get("job_name") != name]
    data["scrape_configs"].append(job)

set_job("node_exporter", [*(f"{i}:9100" for i in brokers), *(f"{i}:9100" for i in controllers), f"{connect}:9100", f"{obs}:9100"])
set_job("kafka_broker_jmx", [f"{i}:5555" for i in brokers])
set_job("kafka_controller_jmx", [f"{i}:5556" for i in controllers])
set_job("connect_jmx", [f"{connect}:7777", f"{connect}:7778"])

with open(path, "w") as f:
    yaml.safe_dump(data, f)

print("Prometheus targets güncellendi:", path)
PY
