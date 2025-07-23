#!/bin/bash

APP_NAME="evolution-app-production"

echo "🔍 VERIFICANDO CONFIGURAÇÕES DA EVOLUTION API"
echo "=============================================="
echo

echo "📋 Variáveis de Ambiente Atuais:"
heroku config --app $APP_NAME | grep -E "(LOG_LEVEL|NODE_OPTIONS|DATABASE_SAVE|WEBHOOK|BAILEYS)"
echo

echo "💾 Uso de Memória Atual:"
heroku ps --app $APP_NAME
echo

echo "📝 Últimas Releases:"
heroku releases --num 5 --app $APP_NAME
echo

echo "🔄 Status dos Dynos:"
heroku ps:type --app $APP_NAME