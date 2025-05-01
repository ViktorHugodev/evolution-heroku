#!/bin/bash
set -e

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
  echo "Uso: ./log-dashboard.sh nome-do-app-heroku"
  exit 1
fi

# Verificar se o Papertrail está instalado
PAPERTRAIL_URL=$(heroku addons:info papertrail --app "$APP_NAME" 2>/dev/null | grep -o 'https://[^ ]*' || echo "")

if [ -z "$PAPERTRAIL_URL" ]; then
  echo "Papertrail não encontrado. Instalando..."
  heroku addons:create papertrail:choklad --app "$APP_NAME"
  PAPERTRAIL_URL=$(heroku addons:info papertrail --app "$APP_NAME" | grep -o 'https://[^ ]*')
fi

echo "Abrindo dashboard do Papertrail..."
heroku addons:open papertrail --app "$APP_NAME"

echo "Comandos úteis para logs:"
echo "1. Ver logs em tempo real: ./log-formatter.sh $APP_NAME"
echo "2. Ver últimos 100 logs: heroku logs -n 100 --app $APP_NAME"
echo "3. Ver logs de erros apenas: heroku logs --app $APP_NAME | grep ERROR"
echo "4. Acessar dashboard web: $PAPERTRAIL_URL"