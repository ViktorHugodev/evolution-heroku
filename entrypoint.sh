#!/bin/sh
set -e

# Script de inicialização automatizado para Evolution API no Heroku
echo "Iniciando configuração automática da Evolution API no Heroku..."

# Usar a porta definida pelo Heroku
if [ -n "$PORT" ]; then
  export SERVER_PORT="$PORT"
  echo "Configurando porta: $PORT"
fi

# Configurar URL do servidor automaticamente
if [ -n "$HEROKU_APP_NAME" ]; then
  export SERVER_URL="https://$HEROKU_APP_NAME.herokuapp.com"
  echo "URL do servidor configurada automaticamente: $SERVER_URL"
fi

# Configurar conexão com PostgreSQL
if [ -n "$DATABASE_URL" ]; then
  # Configurar URI de conexão com PostgreSQL
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
  echo "Conexão com PostgreSQL configurada automaticamente"
fi

# Configurar conexão com Redis
if [ -n "$REDIS_URL" ]; then
  export CACHE_REDIS_URI="$REDIS_URL"
  echo "Conexão com Redis configurada automaticamente"
fi

# Gerar chave de API aleatória se não estiver definida
if [ -z "$AUTHENTICATION_API_KEY" ]; then
  export AUTHENTICATION_API_KEY="$(openssl rand -hex 16)"
  echo "Chave de API gerada automaticamente: $AUTHENTICATION_API_KEY"
  echo "IMPORTANTE: Guarde esta chave para acessar a API"
fi

# Mostrar informações de configuração
echo "==============================================================="
echo "Evolution API configurada com sucesso!"
echo "URL do servidor: $SERVER_URL"
echo "Chave de API: $AUTHENTICATION_API_KEY"
echo "==============================================================="

# Verificar os diretórios e arquivos
echo "Verificando estrutura de arquivos..."
ls -la /evolution
find /evolution -name "*.js" | grep main || echo "Nenhum arquivo main.js encontrado"

# Verificar se existem scripts de inicialização específicos
if [ -f "/evolution/server.js" ]; then
  echo "Iniciando via server.js..."
  exec node /evolution/server.js
elif [ -f "/evolution/app.js" ]; then
  echo "Iniciando via app.js..."
  exec node /evolution/app.js
elif [ -f "/evolution/index.js" ]; then
  echo "Iniciando via index.js..."
  exec node /evolution/index.js
else
  # Tentar iniciar usando o comando padrão do container
  echo "Tentando iniciar com o comando padrão da imagem Docker..."
  exec npm start
fi