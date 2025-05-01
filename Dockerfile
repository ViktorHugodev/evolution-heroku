FROM atendai/evolution-api:latest

WORKDIR /evolution

# Copiar entrypoint personalizado
COPY entrypoint.sh /evolution/entrypoint.sh
RUN chmod +x /evolution/entrypoint.sh

# Verificar conteúdo e estrutura
RUN ls -la /evolution && \
    ls -la /evolution/dist 2>/dev/null || echo "Diretório dist não encontrado"

# Expor a porta que será usada
EXPOSE 8080

# Volume para instâncias
VOLUME ["/evolution/instances"]

# Executar o script de entrada
ENTRYPOINT ["/evolution/entrypoint.sh"]