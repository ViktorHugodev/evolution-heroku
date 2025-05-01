#!/bin/bash
set -e

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
  echo "Uso: ./debug-workflow.sh nome-do-app-heroku"
  exit 1
fi

echo "=== WORKFLOW DE DIAGNÓSTICO DA EVOLUTION API ==="
echo "App: $APP_NAME"
echo

# Verificar status do app
echo "1. Verificando status do app..."
heroku ps --app "$APP_NAME"

# Coletar informações de configuração
echo
echo "2. Verificando variáveis de ambiente críticas..."
heroku config --app "$APP_NAME" | grep -E 'DATABASE_URL|REDIS_URL|SERVER_URL|DATABASE_CONNECTION_URI|CACHE_REDIS_URI|PORT'

# Verificar logs de erros recentes
echo
echo "3. Buscando erros recentes nos logs..."
heroku logs --app "$APP_NAME" | grep -E 'ERROR|Error:|erro|crash|fail|MODULE_NOT_FOUND' | tail -10

# Tentar executar bash dentro do container
echo
echo "4. Tentando acessar o container para diagnóstico interno..."
echo "Isto pode falhar se o contêiner não estiver rodando. Pressione Ctrl+C para pular após 10 segundos se travar."
timeout 10 heroku run bash --app "$APP_NAME" << EOF
echo "Dentro do container!"
ls -la /evolution
find / -name "main.js" | head -5
find / -name "server.js" | head -5
find / -name "app.js" | head -5
cat /evolution/package.json 2>/dev/null | grep -E '"main"|"start"' || echo "package.json não encontrado"
exit
EOF

# Checar estado dos add-ons
echo
echo "5. Verificando estado dos add-ons..."
heroku addons --app "$APP_NAME"

# Verificar o Papertrail
echo
echo "6. Verificando logs no Papertrail..."
if heroku addons | grep -q papertrail; then
  echo "Papertrail instalado. Últimos 5 logs:"
  heroku addons:open papertrail --app "$APP_NAME"
else
  echo "Papertrail não instalado. Instalando..."
  heroku addons:create papertrail:choklad --app "$APP_NAME"
fi

# Instruções finais
echo
echo "7. Ações recomendadas:"
echo "- Verificar se o Dockerfile e entrypoint.sh estão configurados corretamente"
echo "- Executar './log-formatter.sh $APP_NAME' para ver logs formatados em tempo real"
echo "- Reiniciar o aplicativo: heroku restart --app $APP_NAME"
echo "- Considerar redeployment com as correções: git push heroku main"
echo
echo "Diagnóstico concluído!"