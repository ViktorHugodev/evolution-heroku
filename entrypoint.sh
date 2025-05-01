#!/bin/sh

echo "[entrypoint] Iniciando configuração da Evolution API no Heroku..."

# Garante que as variáveis estejam disponíveis
export REDIS_URL="${REDIS_TLS_URL:-$REDIS_URL}"

# Debug: mostra a URL em uso (sem expor senha)
echo "[entrypoint] Redis URL em uso: $(echo "$REDIS_URL" | sed 's/:.*@/:***@/')"

# Aplica migrations do Prisma (somente se DATABASE_PROVIDER for definido)
if [ "$DATABASE_PROVIDER" = "posgresql" ]; then
  echo "[entrypoint] Rodando migrations do Prisma..."
  npx prisma migrate deploy --schema=prisma/postgresql-schema.prisma
fi

# Gera Prisma Client (evita erro se .prisma foi alterado)
echo "[entrypoint] Gerando Prisma Client..."
npx prisma generate --schema=prisma/postgresql-schema.prisma

# Inicia aplicação
echo "[entrypoint] Iniciando aplicação..."
exec node dist/main.js
