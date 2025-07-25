#!/bin/bash

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
  echo "Uso: ./deploy-commands.sh evolution-app-test"
  exit 1
fi

echo "=== COMANDOS DE DEPLOY PARA EVOLUTION API ==="
echo "App: $APP_NAME"
echo

# Comandos para criar e configurar o app
echo "1. Criar o app no Heroku:"
echo "heroku create $APP_NAME --stack=container"
echo

echo "2. Adicionar add-ons:"
echo "heroku addons:create heroku-postgresql:essential-0 --app $APP_NAME"
echo "heroku addons:create heroku-redis:mini --app $APP_NAME"
echo "heroku addons:create papertrail:choklad --app $APP_NAME"
echo

echo "3. Configurar variáveis de ambiente:"
echo "heroku config:set SERVER_URL=https://$APP_NAME.herokuapp.com --app $APP_NAME"
echo "heroku config:set HEROKU_APP_NAME=$APP_NAME --app $APP_NAME"
echo "heroku config:set NODE_ENV=production --app $APP_NAME"
echo "heroku config:set AUTHENTICATION_API_KEY=\$(openssl rand -hex 16) --app $APP_NAME"
echo

echo "4. Configurações adicionais para correção do problema:"
echo "heroku config:set DATABASE_SAVE_DATA_NEW_MESSAGE=true --app $APP_NAME"
echo "heroku config:set CONFIG_SESSION_PHONE_CLIENT=EvolutionAPI --app $APP_NAME"
echo "heroku config:set CONFIG_SESSION_PHONE_NAME=Chrome --app $APP_NAME"
echo "heroku config:set WEBHOOK_GLOBAL_ENABLED=false --app $APP_NAME"
echo

echo "5. Deploy do app:"
echo "git add ."
echo "git commit -m \"fix: corrigir problemas de inicialização\""
echo "git push heroku main"
echo

echo "6. Verificar logs:"
echo "heroku logs --tail --app $APP_NAME"
echo

echo "7. Forçar restart se necessário:"
echo "heroku restart --app $APP_NAME"
echo

echo "8. Abrir app no navegador:"
echo "heroku open --app $APP_NAME"