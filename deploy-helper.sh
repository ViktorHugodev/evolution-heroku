#!/bin/bash
set -e

# Obter o nome do aplicativo Heroku
if [ -z "$1" ]; then
  echo "Uso: ./deploy-helper.sh nome-do-app-heroku"
  exit 1
fi

APP_NAME="$1"

# Criar o app no Heroku se não existir
heroku apps:info "$APP_NAME" > /dev/null 2>&1 || heroku create "$APP_NAME" --stack=container

# Configurar os add-ons
echo "Configurando add-ons..."
heroku addons:create heroku-postgresql:essential-0 --app "$APP_NAME" || echo "PostgreSQL já configurado"
heroku addons:create heroku-redis:mini --app "$APP_NAME" || echo "Redis já configurado"

# Configurar variáveis de ambiente
echo "Configurando variáveis de ambiente..."
heroku config:set SERVER_URL="https://$APP_NAME.herokuapp.com" --app "$APP_NAME"
heroku config:set AUTHENTICATION_API_KEY="$(openssl rand -hex 16)" --app "$APP_NAME"

# Fazer deploy
echo "Realizando deploy..."
git push heroku main

echo "Deploy concluído! Verifique os logs com: heroku logs --tail --app $APP_NAME"