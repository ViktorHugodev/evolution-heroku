#!/bin/sh
set -e

echo "[EVOLUTION-API] Iniciando configuração para Heroku..."

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

# Diagnóstico
echo "[EVOLUTION-API] ===== INFORMAÇÕES DO AMBIENTE ====="
echo "[EVOLUTION-API] Diretório atual: $(pwd)"
echo "[EVOLUTION-API] Arquivos em /evolution:"
ls -la /evolution
echo "[EVOLUTION-API] Verificando main.js:"
ls -la /evolution/dist/main.js || echo "Arquivo main.js não encontrado"

# Aplicar migrations do Prisma com flag para aceitar perda de dados
echo "[EVOLUTION-API] Aplicando migrations do Prisma..."
if ! npx prisma db push --schema=/evolution/prisma/postgresql-schema.prisma --accept-data-loss; then
    echo "[AVISO] Falha ao aplicar migrations, tentando com force-reset..."
    npx prisma db push --schema=/evolution/prisma/postgresql-schema.prisma --force-reset --accept-data-loss || echo "[AVISO] Force reset também falhou"
fi

# Gerar cliente Prisma
echo "[EVOLUTION-API] Gerando cliente Prisma..."
npx prisma generate --schema=/evolution/prisma/postgresql-schema.prisma || echo "[AVISO] Falha ao gerar cliente"

# Iniciar aplicação
echo "[EVOLUTION-API] Iniciando aplicação diretamente via node /evolution/dist/main.js"
exec node /evolution/dist/main.js