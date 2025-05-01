#!/bin/sh
set -e

# Script de inicialização otimizado para Evolution API no Heroku
echo "[EVOLUTION-API] Iniciando configuração para Heroku..."

# Configurar porta do servidor
if [ -n "$PORT" ]; then
  export SERVER_PORT="$PORT"
  echo "[EVOLUTION-API] Porta configurada: $PORT"
fi

# Configurar URL do servidor
if [ -n "$HEROKU_APP_NAME" ]; then
  export SERVER_URL="https://$HEROKU_APP_NAME.herokuapp.com"
  echo "[EVOLUTION-API] URL do servidor: $SERVER_URL"
fi

# Configurar conexão com PostgreSQL
if [ -n "$DATABASE_URL" ]; then
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
  echo "[EVOLUTION-API] Conexão com PostgreSQL configurada"
fi

# Configurar conexão com Redis
if [ -n "$REDIS_URL" ]; then
  export CACHE_REDIS_URI="$REDIS_URL"
  echo "[EVOLUTION-API] Conexão com Redis configurada"
fi

# Mostrar informações de ambiente
echo "[EVOLUTION-API] ===== INFORMAÇÕES DO AMBIENTE ====="
echo "[EVOLUTION-API] Diretório atual: $(pwd)"
echo "[EVOLUTION-API] Arquivos em /evolution:"
ls -la /evolution
echo "[EVOLUTION-API] Verificando main.js:"
ls -la /evolution/dist/main.js || echo "Arquivo main.js não encontrado"

# Verificar package.json
echo "[EVOLUTION-API] Verificando package.json:"
cat /evolution/package.json | grep -A 5 '"scripts"'
# Rodar migrations se a tabela "Instance" não existir
echo "[EVOLUTION-API] Verificando se migrations já foram aplicadas..."
HAS_INSTANCE_TABLE=$(psql "$DATABASE_URL" -tAc "SELECT to_regclass('public.\"Instance\"');")

if [ "$HAS_INSTANCE_TABLE" = "" ]; then
  echo "[EVOLUTION-API] Tabela 'Instance' não encontrada. Aplicando migrations via 'npm run db:deploy'..."
  npm run db:deploy || echo "[EVOLUTION-API] ⚠️ Erro ao rodar 'npm run db:deploy'"
else
  echo "[EVOLUTION-API] Tabela 'Instance' detectada. Migrations já aplicadas."
fi

# Método 1: Iniciar diretamente com node
if [ -f "/evolution/dist/main.js" ]; then
  echo "[EVOLUTION-API] Iniciando aplicação diretamente via node /evolution/dist/main.js"
  cd /evolution && NODE_ENV=production node /evolution/dist/main.js
else
  # Método 2: Tentar iniciar com npm start
  echo "[EVOLUTION-API] Método 1 falhou, tentando npm start..."
  cd /evolution && NODE_ENV=production npm start
fi