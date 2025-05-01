#!/bin/sh
set -e

# Script de inicialização automatizado para Evolution API no Heroku
echo "[EVOLUTION-API] Iniciando configuração automática da Evolution API no Heroku..."

# Usar a porta definida pelo Heroku
if [ -n "$PORT" ]; then
  export SERVER_PORT="$PORT"
  echo "[EVOLUTION-API] Configurando porta: $PORT"
fi

# Configurar URL do servidor automaticamente
if [ -n "$HEROKU_APP_NAME" ]; then
  export SERVER_URL="https://$HEROKU_APP_NAME.herokuapp.com"
  echo "[EVOLUTION-API] URL do servidor configurada automaticamente: $SERVER_URL"
else
  # Tentar obter o nome do app das variáveis de ambiente do Heroku
  APP_NAME=$(echo $DYNO | cut -d'.' -f1)
  if [ -n "$APP_NAME" ]; then
    export SERVER_URL="https://$APP_NAME.herokuapp.com"
    echo "[EVOLUTION-API] URL do servidor definida como: $SERVER_URL (baseado no nome do dyno)"
  fi
fi

# Configurar conexão com PostgreSQL
if [ -n "$DATABASE_URL" ]; then
  # Configurar URI de conexão com PostgreSQL
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
  echo "[EVOLUTION-API] Conexão com PostgreSQL configurada automaticamente"
fi

# Configurar conexão com Redis
if [ -n "$REDIS_URL" ]; then
  export CACHE_REDIS_URI="$REDIS_URL"
  echo "[EVOLUTION-API] Conexão com Redis configurada automaticamente"
fi

# Gerar chave de API aleatória se não estiver definida
if [ -z "$AUTHENTICATION_API_KEY" ]; then
  export AUTHENTICATION_API_KEY="$(openssl rand -hex 16)"
  echo "[EVOLUTION-API] Chave de API gerada automaticamente: $AUTHENTICATION_API_KEY"
  echo "[EVOLUTION-API] IMPORTANTE: Guarde esta chave para acessar a API"
fi

# Mostrar informações de configuração
echo "[EVOLUTION-API] ==========================================================="
echo "[EVOLUTION-API] Evolution API configurada com sucesso!"
echo "[EVOLUTION-API] URL do servidor: $SERVER_URL"
echo "[EVOLUTION-API] Chave de API: $AUTHENTICATION_API_KEY"
echo "[EVOLUTION-API] ==========================================================="

# Verifica a estrutura de arquivos da imagem
echo "[EVOLUTION-API] Debug - Verificando estrutura da imagem:"
echo "[EVOLUTION-API] Conteúdo do diretório /evolution:"
ls -la /evolution 2>&1 | sed 's/^/[EVOLUTION-API] /'

echo "[EVOLUTION-API] Procurando pontos de entrada:"
find /evolution -name "*.js" -type f | grep -E 'server\.js|app\.js|index\.js|main\.js' 2>&1 | sed 's/^/[EVOLUTION-API] /'

echo "[EVOLUTION-API] Verificando package.json:"
if [ -f "/evolution/package.json" ]; then
  cat /evolution/package.json | grep -E '"start"|"main"' 2>&1 | sed 's/^/[EVOLUTION-API] /'
fi

# Verificar se existem scripts de inicialização específicos
echo "[EVOLUTION-API] Tentando iniciar o servidor..."

# Verificar se existe um comando de inicialização específico
if [ -f "/evolution/package.json" ]; then
  START_COMMAND=$(cat /evolution/package.json | grep -o '"start": "[^"]*"' | sed 's/"start": "\(.*\)"/\1/')
  
  if [ -n "$START_COMMAND" ]; then
    echo "[EVOLUTION-API] Iniciando via comando npm start ($START_COMMAND)..."
    cd /evolution && npm start
    exit 0
  fi
fi

# Tentar encontrar e executar o ponto de entrada
if [ -f "/evolution/dist/src/main.js" ]; then
  echo "[EVOLUTION-API] Encontrado arquivo main.js, iniciando..."
  exec node /evolution/dist/src/main.js
elif [ -f "/evolution/server.js" ]; then
  echo "[EVOLUTION-API] Iniciando via server.js..."
  exec node /evolution/server.js
elif [ -f "/evolution/app.js" ]; then
  echo "[EVOLUTION-API] Iniciando via app.js..."
  exec node /evolution/app.js
elif [ -f "/evolution/index.js" ]; then
  echo "[EVOLUTION-API] Iniciando via index.js..."
  exec node /evolution/index.js
else
  # Tentativa final - assumir estrutura padrão e tentar executar
  echo "[EVOLUTION-API] Arquivos principais não encontrados. Tentando variações de caminhos..."
  POTENTIAL_PATHS=(
    "/app/dist/main.js"
    "/app/dist/src/main.js"
    "/evolution/build/main.js"
    "/evolution/build/src/main.js"
    "/evolution/src/main.js"
  )
  
  for path in "${POTENTIAL_PATHS[@]}"; do
    if [ -f "$path" ]; then
      echo "[EVOLUTION-API] Encontrado arquivo em $path, tentando iniciar..."
      exec node "$path"
      break
    fi
  done
  
  echo "[EVOLUTION-API] Nenhum ponto de entrada conhecido encontrado. Executando comando padrão da imagem..."
  # Tenta executar o comando padrão da imagem Docker
  if [ -f "/docker-entrypoint.sh" ]; then
    exec /docker-entrypoint.sh
  elif [ -f "/.docker/entrypoint.sh" ]; then
    exec /.docker/entrypoint.sh
  else
    echo "[EVOLUTION-API] ERRO FATAL: Não foi possível iniciar a aplicação!"
    exit 1
  fi
fi