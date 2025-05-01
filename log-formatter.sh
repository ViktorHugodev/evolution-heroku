#!/bin/bash
set -e

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
  echo "Uso: ./log-formatter.sh nome-do-app-heroku"
  exit 1
fi

# Cores para logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
RESET='\033[0m'

# Função para formatar os logs
format_log() {
  while IFS= read -r line; do
    # Colorização baseada no tipo de log
    if [[ $line == *"ERROR"* ]] || [[ $line == *"error"* ]]; then
      echo -e "${RED}$line${RESET}"
    elif [[ $line == *"WARN"* ]] || [[ $line == *"warn"* ]]; then
      echo -e "${YELLOW}$line${RESET}"
    elif [[ $line == *"DEBUG"* ]] || [[ $line == *"debug"* ]]; then
      echo -e "${CYAN}$line${RESET}"
    elif [[ $line == *"INFO"* ]] || [[ $line == *"info"* ]]; then
      echo -e "${GREEN}$line${RESET}"
    elif [[ $line == *"EVOLUTION-API"* ]]; then
      echo -e "${MAGENTA}$line${RESET}"
    elif [[ $line == *"heroku"* ]]; then
      echo -e "${GRAY}$line${RESET}"
    else
      echo -e "$line"
    fi
  done
}

echo "Iniciando monitoramento de logs para $APP_NAME com formatação..."
heroku logs --tail --app "$APP_NAME" | format_log