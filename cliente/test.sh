#!/bin/bash

# Uso: bash test.sh <IP_PC2>
# Ejemplo: bash test.sh 192.168.1.50

IP_EDGE=$1

if [ -z "$IP_EDGE" ]; then
  echo "Error: falta la IP del edge server."
  echo "Uso: bash test.sh <IP_PC2>"
  exit 1
fi

URL="http://$IP_EDGE/video/index.m3u8"

echo "======================================="
echo "  CDN Maqueta - Test de cache"
echo "======================================="
echo "Edge server: $IP_EDGE"
echo "URL: $URL"
echo ""

echo "--- Solicitud 1 (esperado: MISS) ---"
RESPONSE1=$(curl -s -o /dev/null -w "%{time_total}|%header{x-cache-status}" -I "$URL")
TIME1=$(echo $RESPONSE1 | cut -d'|' -f1)
STATUS1=$(echo $RESPONSE1 | cut -d'|' -f2)
echo "X-Cache-Status: $STATUS1"
echo "Tiempo: ${TIME1}s"
echo ""

sleep 1

echo "--- Solicitud 2 (esperado: HIT) ---"
RESPONSE2=$(curl -s -o /dev/null -w "%{time_total}|%header{x-cache-status}" -I "$URL")
TIME2=$(echo $RESPONSE2 | cut -d'|' -f1)
STATUS2=$(echo $RESPONSE2 | cut -d'|' -f2)
echo "X-Cache-Status: $STATUS2"
echo "Tiempo: ${TIME2}s"
echo ""

echo "======================================="
echo "  Resultado"
echo "======================================="
echo "Primera solicitud:  ${TIME1}s"
echo "Segunda solicitud:  ${TIME2}s"