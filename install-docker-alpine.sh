#!/bin/sh
# Instala y prepara Docker + Docker Compose en Alpine Linux
set -eu

# Debe ejecutarse como root
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root (o con doas/sudo)"; exit 1; }

# 1. Habilitar repositorio community (descomenta la línea si está comentada)
sed -i -E '/\/v[0-9]+\.[0-9]+\/community/ s/^#//' /etc/apk/repositories
if ! grep -qE '^[^#].*/community' /etc/apk/repositories; then
  VER=$(cut -d. -f1,2 /etc/alpine-release)
  echo "https://dl-cdn.alpinelinux.org/alpine/v${VER}/community" >> /etc/apk/repositories
fi

# 2. Instalar paquetes
apk update
apk add docker docker-cli-compose

# 3. Arrancar al inicio e iniciar ahora
rc-update add docker default
service docker start || true

# 4. Añadir usuario al grupo docker (opcional: ./script.sh miusuario)
if [ "${1:-}" ]; then
  addgroup "$1" docker
  echo "Usuario $1 añadido al grupo docker (reinicia sesión)."
fi

# 5. Verificar
sleep 2
docker --version
docker compose version
docker run --rm hello-world