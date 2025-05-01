#!/bin/bash

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
  echo "Uso: ./fix-startup.sh evolution-app-test"
  exit 1
fi

# Cores para formatação
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== DIAGNÓSTICO E CORREÇÃO DA EVOLUTION API =====${NC}"
echo -e "${BLUE}App: $APP_NAME${NC}"
echo

# Verificar status atual
echo -e "${YELLOW}1. Verificando status atual...${NC}"
heroku ps --app "$APP_NAME"
echo

# Verificar logs recentes
echo -e "${YELLOW}2. Verificando logs de erro recentes...${NC}"
heroku logs --app "$APP_NAME" --num 50 | grep -E "Error:|error|fail|crash" | tail -5
echo

# Examinar estrutura do container
echo -e "${YELLOW}3. Examinando estrutura do container...${NC}"
echo "Executando comando no container para verificar arquivos..."
heroku run "ls -la /evolution && ls -la /evolution/dist && cat /evolution/package.json | grep -A 5 scripts" --app "$APP_NAME" || echo "Não foi possível acessar o container"
echo

# Reiniciar aplicação
echo -e "${YELLOW}4. Reiniciando aplicação...${NC}"
heroku restart --app "$APP_NAME"
echo "Aguardando reinicialização..."
sleep 5
echo

# Verificar status após reinicialização
echo -e "${YELLOW}5. Verificando status após reinicialização...${NC}"
heroku ps --app "$APP_NAME"
echo

# Verificar logs após reinicialização
echo -e "${YELLOW}6. Verificando logs após reinicialização...${NC}"
heroku logs --app "$APP_NAME" --num 20 | tail -10
echo

echo -e "${GREEN}===== INSTRUÇÕES ADICIONAIS =====${NC}"
echo "1. Para monitorar logs em tempo real: heroku logs --tail --app $APP_NAME"
echo "2. Para acessar o dashboard do Papertrail: heroku addons:open papertrail --app $APP_NAME"
echo "3. Para verificar variáveis de ambiente: heroku config --app $APP_NAME"
echo
echo -e "${YELLOW}Se o app continuar com problemas, tente editar o entrypoint.sh e fazer deploy novamente.${NC}"