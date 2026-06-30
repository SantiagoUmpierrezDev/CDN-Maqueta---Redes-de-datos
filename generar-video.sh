#!/bin/bash

# Genera un video de prueba en formato HLS usando ffmpeg
# Requiere ffmpeg instalado

OUTPUT_DIR="origen/video"

echo "Generando video HLS de prueba..."

ffmpeg -f lavfi -i testsrc=duration=30:size=640x360:rate=30 \
  -f lavfi -i sine=frequency=440:duration=30 \
  -c:v libx264 -preset fast -crf 28 \
  -c:a aac -b:a 64k \
  -hls_time 4 \
  -hls_list_size 0 \
  -hls_segment_filename "$OUTPUT_DIR/segment%03d.ts" \
  -f hls "$OUTPUT_DIR/index.m3u8"

echo ""
echo "Archivos generados en $OUTPUT_DIR:"
ls -lh $OUTPUT_DIR
