#!/bin/sh

echo "[entrypoint] Iniciando configuração da Evolution API no Heroku..."

# --- Redis ---
export REDIS_URL="${REDIS_TLS_URL:-$REDIS_URL}"
echo "[entrypoint] Redis URL em uso: $(echo "$REDIS_URL" | sed 's/:.*@/:***@/')"

# --- PostgreSQL ---
export DATABASE_URL="${DATABASE_URL}"
echo "[entrypoint] DATABASE_URL: $(echo "$DATABASE_URL" | sed 's/:.*@/:***@/')"

# --- Prisma Migrations ---
if [ "$DATABASE_PROVIDER" = "posgresql" ]; then
  echo "[entrypoint] Rodando migrations do Prisma..."
  npx prisma migrate deploy --schema=prisma/postgresql-schema.prisma
fi

# --- Prisma Client ---
echo "[entrypoint] Gerando Prisma Client..."
npx prisma generate --schema=prisma/postgresql-schema.prisma

# --- Iniciar aplicação ---
echo "[entrypoint] Iniciando aplicação..."
exec node dist/main.js
