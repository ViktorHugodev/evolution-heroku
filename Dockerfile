FROM atendai/evolution-api:latest

# Copiar nosso entrypoint customizado
COPY entrypoint.sh /evolution/entrypoint.sh
RUN chmod +x /evolution/entrypoint.sh

# Verificar a estrutura de diretórios e arquivos
RUN ls -la /evolution
RUN find / -name "server.js" -o -name "main.js" -o -name "app.js" 2>/dev/null || echo "Nenhum arquivo de entrada encontrado"

# Manter a porta e o volume
EXPOSE 8080
VOLUME ["/evolution/instances"]

# Definir o entrypoint
ENTRYPOINT ["/evolution/entrypoint.sh"]