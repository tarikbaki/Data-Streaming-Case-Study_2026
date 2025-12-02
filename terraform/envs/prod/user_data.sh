#!/bin/bash
# Basit cloud-init: güncelleme + ncat ile kontrol
apt-get update -y || true
apt-get install -y netcat || true
