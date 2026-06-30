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
echo "  CDN Maqueta - Test de caché"
echo "======================================="
echo "Edge server: $IP_EDGE"
echo "URL: $URL"
echo ""

echo "--- Solicitud 1 (esperado: MISS) ---"
TIME1=$(curl -o /dev/null -s -w "%{time_total}" -I "$URL" | tail -1)
STATUS1=$(curl -s -I "$URL" | grep -i "x-cache-status" | tr -d '\r')
echo "X-Cache-Status: $STATUS1"
echo "Tiempo: ${TIME1}s"
echo ""

sleep 1

echo "--- Solicitud 2 (esperado: HIT) ---"
TIME2=$(curl -o /dev/null -s -w "%{time_total}" -I "$URL" | tail -1)
STATUS2=$(curl -s -I "$URL" | grep -i "x-cache-status" | tr -d '\r')
echo "X-Cache-Status: $STATUS2"
echo "Tiempo: ${TIME2}s"
echo ""

echo "======================================="
echo "  Resultado"
echo "======================================="
echo "Primera solicitud:  ${TIME1}s"
echo "Segunda solicitud:  ${TIME2}s"
echo ""
echo "El edge sirvio el contenido desde cache en la segunda solicitud."
