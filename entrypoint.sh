#!/bin/sh

echo "=== INICIANDO EVOLUTION API ==="

# Configuração da porta
if [ -n "${PORT+x}" ]; then
  export SERVER_PORT="$PORT"
  echo "Usando porta: $PORT"
fi

# Configuração do PostgreSQL
if [ -n "${DATABASE_URL+x}" ]; then
  echo "Configurando PostgreSQL"
  
  # Extrair componentes da URL
  DB_URI="${DATABASE_URL}"
  
  # Configurar variáveis para o PostgreSQL
  export DATABASE_PROVIDER=postgresql
  export DATABASE_CONNECTION_URI="${DB_URI}?ssl=true"
fi

# Configuração do Redis
if [ -n "${REDIS_URL+x}" ]; then
  echo "Configurando Redis"
  export CACHE_REDIS_ENABLED=true
  export CACHE_REDIS_URI="${REDIS_URL}"
fi

echo "Iniciando aplicação Node.js..."
cd /evolution
exec node --max-old-space-size=512 dist/src/main.js