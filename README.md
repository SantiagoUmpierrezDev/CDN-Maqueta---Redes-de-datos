# CDN Maqueta — Docker + Nginx

Simulación de una arquitectura CDN con 3 nodos independientes.  
Trabajo práctico — Redes de Datos, UCU.

## Arquitectura

```
PC 1 (Origen)          PC 2 (Edge Server)        PC 3 (Cliente)
Nginx :8080    →→→     Nginx + caché :80    →→→   curl / navegador
```

---

## Requisitos

- Docker instalado en PC 1 y PC 2
- Las 3 PCs en la misma red local (WiFi o LAN)
- `curl` en PC 3 (viene por defecto en Linux/Mac; en Windows usar Git Bash)

---

## PC 1 — Servidor de Origen

### 1. Generar el video HLS (solo una vez)

Necesitás `ffmpeg` instalado:
```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# Mac
brew install ffmpeg
```

Luego desde la raíz del proyecto:
```bash
bash generar-video.sh
```

Esto genera los archivos `.m3u8` y `.ts` en `origen/video/`.

### 2. Buildear y correr el contenedor

```bash
cd origen
docker build -t cdn-origen .
docker run -p 8080:8080 cdn-origen
```

### 3. Verificar que funciona

Desde la misma PC:
```bash
curl -I http://localhost:8080/video/index.m3u8
```
Deberías ver `200 OK`.

### 4. Anotar la IP de esta PC

```bash
# Linux/Mac
ip addr show | grep "inet "

# Windows
ipconfig
```
Compartí esta IP con quien va a configurar PC 2.

---

## PC 2 — Edge Server

### 1. Editar nginx.conf

Abrí `edge/nginx.conf` y reemplazá `IP_PC1` con la IP real de PC 1:

```nginx
set $origen http://192.168.1.XX:8080;   ← reemplazá esto
```

### 2. Buildear y correr el contenedor

```bash
cd edge
docker build -t cdn-edge .
docker run -p 80:80 cdn-edge
```

### 3. Verificar que funciona

```bash
curl -I http://localhost/video/index.m3u8
```
Deberías ver el header `X-Cache-Status: MISS` en la primera solicitud.

### 4. Anotar la IP de esta PC

Compartí esta IP con quien va a ejecutar las pruebas desde PC 3.

---

## PC 3 — Cliente

No necesita Docker. Desde la terminal:

```bash
bash cliente/test.sh IP_PC2
```

Ejemplo:
```bash
bash cliente/test.sh 192.168.1.50
```

### Resultado esperado

```
--- Solicitud 1 (esperado: MISS) ---
X-Cache-Status: MISS
Tiempo: 0.245s

--- Solicitud 2 (esperado: HIT) ---
X-Cache-Status: HIT
Tiempo: 0.018s
```

La segunda solicitud es significativamente más rápida porque el edge server
la sirve desde su caché sin contactar al servidor de origen.

---

## Estructura del proyecto

```
cdn-maqueta/
├── README.md
├── generar-video.sh       ← genera los archivos HLS con ffmpeg
├── origen/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── video/             ← archivos .m3u8 y .ts generados
├── edge/
│   ├── Dockerfile
│   └── nginx.conf         ← editar IP_PC1 antes de buildear
└── cliente/
    └── test.sh            ← script de prueba con curl
```
