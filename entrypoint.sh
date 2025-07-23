#!/bin/sh
set -e

echo "[EVOLUTION-API] Iniciando configuração para Heroku..."

# Configurações básicas (SEM FLAGS PROBLEMÁTICAS)
export NODE_OPTIONS="--max-old-space-size=350"
export NODE_ENV=production
export LOG_LEVEL="ERROR"

# Porta padrão do Heroku
if [ -n "$PORT" ]; then
  export SERVER_PORT="$PORT"
  echo "[EVOLUTION-API] Porta: $PORT"
fi

# Define SERVER_URL
if [ -n "$HEROKU_APP_NAME" ]; then
  export SERVER_URL="https://$HEROKU_APP_NAME.herokuapp.com"
fi

# PostgreSQL
if [ -n "$DATABASE_URL" ]; then
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
fi

# Redis
if [ -n "$REDIS_URL" ]; then
  export CACHE_REDIS_URI="$(echo "$REDIS_URL" | sed 's/^rediss:/redis:/')"
fi

echo "[EVOLUTION-API] Configurações aplicadas"

# Iniciar aplicação (SEM FLAGS PROBLEMÁTICAS)
echo "[EVOLUTION-API] Iniciando aplicação..."
exec node --max-old-space-size=350 /evolution/dist/main.js