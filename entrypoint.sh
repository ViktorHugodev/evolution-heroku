#!/bin/sh

echo "[entrypoint] Iniciando configuração da Evolution API no Heroku..."

# Apaga .env se existir para evitar conflitos com variáveis de ambiente reais do Heroku
rm -f .env

# Log de variáveis principais para debug
echo "[entrypoint] Redis URL em uso: ${REDIS_URL:-$REDIS_TLS_URL}"
echo "[entrypoint] DATABASE_URL: ${DATABASE_URL}"

# Garante que Prisma use a DATABASE_URL correta
export DATABASE_URL="${DATABASE_URL}"

# Diretório do schema correto
PRISMA_SCHEMA_PATH="./prisma/postgresql-schema.prisma"

echo "[entrypoint] Rodando migrations do Prisma..."
npx prisma migrate deploy --schema="$PRISMA_SCHEMA_PATH"

echo "[entrypoint] Gerando Prisma Client..."
npx prisma generate --schema="$PRISMA_SCHEMA_PATH"

echo "[entrypoint] Iniciando aplicação..."
node dist/main.js
