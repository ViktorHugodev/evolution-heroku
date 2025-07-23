#!/bin/sh
set -e

echo "[EVOLUTION-API] Iniciando configuração otimizada para Heroku..."

# Configurações de memória
export NODE_OPTIONS="--max-old-space-size=400 --optimize-for-size"
export UV_THREADPOOL_SIZE=4

# Porta padrão do Heroku
if [ -n "$PORT" ]; then
  export SERVER_PORT="$PORT"
  echo "[EVOLUTION-API] Porta configurada: $PORT"
fi

# Define SERVER_URL
if [ -n "$HEROKU_APP_NAME" ]; then
  export SERVER_URL="https://$HEROKU_APP_NAME.herokuapp.com"
  echo "[EVOLUTION-API] URL do servidor: $SERVER_URL"
fi

# PostgreSQL
if [ -n "$DATABASE_URL" ]; then
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
  echo "[EVOLUTION-API] Conexão com PostgreSQL configurada"
fi

# Redis
if [ -n "$REDIS_URL" ]; then
  export CACHE_REDIS_URI="$(echo "$REDIS_URL" | sed 's/^rediss:/redis:/')"
  echo "[EVOLUTION-API] Conexão com Redis configurada"
fi

# Configurações para reduzir logs e uso de memória
export LOG_LEVEL="ERROR,WARN"
export BAILEYS_LOGGER_LEVEL="error"
export DATABASE_SAVE_DATA_NEW_MESSAGE=false
export WEBHOOK_GLOBAL_ENABLED=false
export WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS=false

echo "[EVOLUTION-API] Configurações de otimização aplicadas"

# Reset completo do banco na primeira execução
echo "[EVOLUTION-API] Aplicando reset completo do banco..."
if npx prisma db push --schema=/evolution/prisma/postgresql-schema.prisma --force-reset --accept-data-loss; then
    echo "[EVOLUTION-API] Reset do banco realizado com sucesso"
else
    echo "[AVISO] Falha no reset, tentando push normal..."
    npx prisma db push --schema=/evolution/prisma/postgresql-schema.prisma --accept-data-loss || echo "[AVISO] Push também falhou"
fi

# Gerar cliente Prisma
echo "[EVOLUTION-API] Gerando cliente Prisma..."
npx prisma generate --schema=/evolution/prisma/postgresql-schema.prisma || echo "[AVISO] Falha ao gerar cliente"

# Limpeza de memória antes de iniciar
echo "[EVOLUTION-API] Limpando cache e forçando garbage collection..."
node -e "if (global.gc) { global.gc(); console.log('GC executado'); }" || echo "GC não disponível"

# Iniciar aplicação com configurações otimizadas
echo "[EVOLUTION-API] Iniciando aplicação com otimizações..."
exec node --max-old-space-size=400 --optimize-for-size /evolution/dist/main.js