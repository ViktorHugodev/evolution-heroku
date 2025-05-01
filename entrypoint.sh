#!/bin/sh
set -e

echo "[EVOLUTION-API] Iniciando configuração para Heroku..."

if [ -n "$PORT" ]; then
  export SERVER_PORT="$PORT"
  echo "[EVOLUTION-API] Porta configurada: $PORT"
fi

if [ -n "$HEROKU_APP_NAME" ]; then
  export SERVER_URL="https://$HEROKU_APP_NAME.herokuapp.com"
  echo "[EVOLUTION-API] URL do servidor: $SERVER_URL"
fi

if [ -n "$DATABASE_URL" ]; then
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
  echo "[EVOLUTION-API] Conexão com PostgreSQL configurada"
fi

# Suporte ao Redis com TLS (rediss://)
if [ -n "$REDIS_URL" ]; then
  export CACHE_REDIS_URI="$REDIS_URL"
  export CACHE_REDIS_TLS_ENABLED=true
  echo "[EVOLUTION-API] Conexão com Redis configurada (TLS ativado)"
fi

echo "[EVOLUTION-API] ===== INFORMAÇÕES DO AMBIENTE ====="
echo "[EVOLUTION-API] Diretório atual: $(pwd)"
ls -la /evolution

echo "[EVOLUTION-API] Verificando main.js:"
ls -la /evolution/dist/main.js || echo "Arquivo main.js não encontrado"

echo "[EVOLUTION-API] Verificando package.json:"
cat /evolution/package.json | grep -A 5 '"scripts"'

# Rodar migrations com schema correto
echo "[EVOLUTION-API] Aplicando migrations do Prisma..."
npx prisma generate --schema=/evolution/prisma/postgresql-schema.prisma || echo "[AVISO] prisma generate falhou"
npx prisma db push --schema=/evolution/prisma/postgresql-schema.prisma || echo "[AVISO] prisma db push falhou"

echo "[EVOLUTION-API] Iniciando aplicação diretamente via node /evolution/dist/main.js"
exec node /evolution/dist/main.js
