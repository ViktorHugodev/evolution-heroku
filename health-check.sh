#!/bin/bash
set -e

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
  echo "Uso: ./health-check.sh nome-do-app-heroku"
  exit 1
fi

APP_URL="https://${APP_NAME}.herokuapp.com"
API_KEY=$(heroku config:get AUTHENTICATION_API_KEY --app "$APP_NAME")

echo "============================================"
echo "Verificação de Saúde - Evolution API no Heroku"
echo "============================================"
echo "App: $APP_NAME"
echo "URL: $APP_URL"
echo

echo "1. Verificando status da aplicação..."
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${APP_URL}")
if [ "$STATUS_CODE" = "200" ] || [ "$STATUS_CODE" = "302" ]; then
  echo "✅ Aplicação respondendo com status $STATUS_CODE"
else
  echo "❌ Aplicação não está respondendo corretamente (status $STATUS_CODE)"
fi

if [ -n "$API_KEY" ]; then
  echo
  echo "2. Testando endpoint de status com API key..."
  STATUS_RESPONSE=$(curl -s -H "apikey: ${API_KEY}" "${APP_URL}/status" || echo "Falha na requisição")
  if [[ "$STATUS_RESPONSE" == *"true"* ]]; then
    echo "✅ API respondendo corretamente"
  else
    echo "❌ API não está respondendo corretamente"
    echo "Resposta: $STATUS_RESPONSE"
  fi
else
  echo "⚠️ API_KEY não encontrada, pulando teste de API"
fi

echo
echo "3. Verificando estado do dyno..."
DYNO_STATE=$(heroku ps --app "$APP_NAME" | grep web | awk '{print $3}')
echo "Estado do dyno: $DYNO_STATE"

echo
echo "4. Verificando uso de recursos..."
heroku ps:utilization --app "$APP_NAME"

echo
echo "5. Verificando add-ons..."
heroku addons --app "$APP_NAME"

echo
echo "6. Últimos 5 logs de erro..."
heroku logs --app "$APP_NAME" | grep -E "ERROR|error|fail|crash" | tail -5

echo
echo "Diagnóstico concluído! Para ver mais detalhes, execute:"
echo "- Ver logs formatados: ./log-formatter.sh $APP_NAME"
echo "- Dashboard de logs: ./log-dashboard.sh $APP_NAME"
echo "- Reiniciar aplicação: heroku restart --app $APP_NAME"