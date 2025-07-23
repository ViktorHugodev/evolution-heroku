#!/bin/sh
set -e

echo "[EVOLUTION-API] Iniciando configuração AGRESSIVA para Heroku..."

# FORÇAR configurações de memória e logs
export NODE_OPTIONS="--max-old-space-size=350 --optimize-for-size --gc-interval=100"
export UV_THREADPOOL_SIZE=2
export NODE_ENV=production

# FORÇAR logs apenas de erro
export LOG_LEVEL="ERROR"
export BAILEYS_LOGGER_LEVEL="silent"
export DEBUG=""

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

# DESABILITAR TUDO que gasta memória
export DATABASE_SAVE_DATA_NEW_MESSAGE=false
export DATABASE_SAVE_DATA_CHAT=false  
export DATABASE_SAVE_DATA_LABEL=false
export DATABASE_SAVE_DATA_CONTACT=false
export WEBHOOK_GLOBAL_ENABLED=false
export WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS=false
export WEBHOOK_EVENTS_APPLICATION_STARTUP=false
export WEBHOOK_EVENTS_QRCODE_UPDATED=false
export WEBHOOK_EVENTS_MESSAGES_SET=false
export WEBHOOK_EVENTS_MESSAGES_UPSERT=false
export WEBHOOK_EVENTS_MESSAGES_UPDATE=false
export WEBHOOK_EVENTS_SEND_MESSAGE=false
export WEBHOOK_EVENTS_CONTACTS_SET=false
export WEBHOOK_EVENTS_CONTACTS_UPSERT=false
export WEBHOOK_EVENTS_CHATS_SET=false
export WEBHOOK_EVENTS_CHATS_UPSERT=false
export WEBHOOK_EVENTS_CONNECTION_UPDATE=false

echo "[EVOLUTION-API] Configurações AGRESSIVAS aplicadas"

# Reset FORÇADO do banco
echo "[EVOLUTION-API] RESET FORÇADO do banco..."
npx prisma db push --schema=/evolution/prisma/postgresql-schema.prisma --force-reset --accept-data-loss --skip-generate || echo "[AVISO] Reset falhou"

# Gerar cliente
echo "[EVOLUTION-API] Gerando cliente..."
npx prisma generate --schema=/evolution/prisma/postgresql-schema.prisma || echo "[AVISO] Generate falhou"

# Iniciar com configurações mínimas
echo "[EVOLUTION-API] Iniciando com configurações MÍNIMAS..."
exec node --max-old-space-size=350 --optimize-for-size --gc-interval=100 /evolution/dist/main.js