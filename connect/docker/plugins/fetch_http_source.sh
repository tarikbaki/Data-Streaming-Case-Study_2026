#!/bin/bash
# HTTP Source connector jarlarini buraya indiriyorum.
# İndirmek için internet gerektiğini unutma.

set -e
mkdir -p "$(dirname "$0")"
cd "$(dirname "$0")"

URL="https://packages.confluent.io/maven/io/confluent/kafka-connect-http/10.7.4/kafka-connect-http-10.7.4.jar"
echo "indiriliyor: $URL"
curl -L "$URL" -o kafka-connect-http-10.7.4.jar
echo "bitti: $(pwd)/kafka-connect-http-10.7.4.jar"
