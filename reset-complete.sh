#!/bin/bash

APP_NAME="evolution-app-production"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔥 RESET COMPLETO DA EVOLUTION API${NC}"
echo -e "${YELLOW}App: $APP_NAME${NC}"
echo

# 1. Parar a aplicação
echo -e "${YELLOW}1. Parando aplicação...${NC}"
heroku ps:scale web=0 --app $APP_NAME
sleep 3

# 2. Reset do PostgreSQL
echo -e "${YELLOW}2. Fazendo reset do banco PostgreSQL...${NC}"
heroku pg:reset DATABASE_URL --confirm $APP_NAME --app $APP_NAME

# 3. Reset do Redis
echo -e "${YELLOW}3. Limpando cache Redis...${NC}"
heroku redis:cli --app $APP_NAME --confirm $APP_NAME -- flushall

# 4. Configurar variáveis para otimização de memória
echo -e "${YELLOW}4. Configurando otimizações...${NC}"
heroku config:set NODE_OPTIONS="--max-old-space-size=350" --app $APP_NAME
heroku config:set LOG_LEVEL="ERROR" --app $APP_NAME
heroku config:set BAILEYS_LOGGER_LEVEL="silent" --app $APP_NAME
heroku config:set DATABASE_SAVE_DATA_NEW_MESSAGE=false --app $APP_NAME
heroku config:set DATABASE_SAVE_DATA_CHAT=false --app $APP_NAME
heroku config:set DATABASE_SAVE_DATA_LABEL=false --app $APP_NAME
heroku config:set DATABASE_SAVE_DATA_CONTACT=false --app $APP_NAME
heroku config:set WEBHOOK_GLOBAL_ENABLED=false --app $APP_NAME
heroku config:set WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS=false --app $APP_NAME
heroku config:set UV_THREADPOOL_SIZE=2 --app $APP_NAME

# 5. Deploy e restart
echo -e "${YELLOW}5. Deploy e restart...${NC}"
git add .
git commit -m "feat: configurações otimizadas para memória"
git push heroku main

# 6. Escalar para cima
echo -e "${YELLOW}6. Iniciando aplicação...${NC}"
heroku ps:scale web=1 --app $APP_NAME

echo -e "${GREEN}✅ Reset completo finalizado!${NC}"
echo -e "${BLUE}Aguarde 2-3 minutos para inicialização.${NC}"
echo
echo -e "${YELLOW}Para monitorar:${NC}"
echo "heroku logs --tail --app $APP_NAME"