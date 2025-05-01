#!/bin/bash
set -e

# Criar um container temporário para inspecionar a imagem
echo "Criando container de debug..."
CONTAINER_ID=$(docker run -d atendai/evolution-api:latest sleep 3600)

# Verificar estrutura de arquivos
echo "Estrutura de diretórios:"
docker exec $CONTAINER_ID find /evolution -type f -name "*.js" | grep -E '(main|index|server|app)\.js'

# Verificar comando de inicialização padrão
echo "Comando padrão da imagem:"
docker inspect --format='{{.Config.Cmd}}' atendai/evolution-api:latest
docker inspect --format='{{.Config.Entrypoint}}' atendai/evolution-api:latest

# Limpar
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID

echo "Debug concluído. Use estas informações para ajustar seu entrypoint.sh"