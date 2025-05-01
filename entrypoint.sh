#!/bin/sh

echo "=== INICIANDO EVOLUTION API ==="

# Verificação da estrutura de diretórios
mkdir -p /evolution/instances
chmod -R 777 /evolution/instances

# Configuração da porta
if [ -n "${PORT+x}" ]; then
  export SERVER_PORT="$PORT"
  echo "Usando porta: $PORT"
fi

# Configuração do PostgreSQL
if [ -n "${DATABASE_URL+x}" ]; then
  echo "Configurando PostgreSQL"
  export DATABASE_PROVIDER=postgresql
  export DATABASE_CONNECTION_URI="${DATABASE_URL}?sslmode=require"
  echo "PostgreSQL configurado com sucesso"
fi

# Configuração do Redis
if [ -n "${REDIS_URL+x}" ]; then
  echo "Configurando Redis"
  export CACHE_REDIS_ENABLED=true
  export CACHE_REDIS_URI="${REDIS_URL}"
  echo "Redis configurado com sucesso"
fi

# Configuração de memória para Node.js
export NODE_OPTIONS="--max-old-space-size=1024"

echo "Iniciando Evolution API..."
cd /evolution
exec node dist/src/main.js