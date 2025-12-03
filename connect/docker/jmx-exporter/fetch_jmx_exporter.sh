#!/bin/bash
# Basit helper: connect jmx exporter jar'ini indirip docker compose icin hazirlar.

set -euo pipefail

VERSION="${VERSION:-0.20.0}"
JAR="jmx_prometheus_javaagent-${VERSION}.jar"
URL="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${VERSION}/${JAR}"

echo "[INFO] Downloading ${JAR}..."
curl -fSL "$URL" -o "$JAR"
echo "[OK] Saved to $(pwd)/${JAR}"
