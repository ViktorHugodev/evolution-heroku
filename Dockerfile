FROM atendai/evolution-api:latest

USER root

WORKDIR /evolution

# Criar diretório para instâncias
RUN mkdir -p /evolution/instances && \
    chmod -R 777 /evolution/instances

# Cópia do script de entrypoint
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Configuração de variáveis de ambiente padrão
ENV NODE_ENV=production
ENV SERVER_TYPE=http
ENV DATABASE_ENABLED=true
ENV DATABASE_PROVIDER=postgresql
ENV CACHE_REDIS_ENABLED=true
ENV NODE_OPTIONS="--max-old-space-size=1024"

CMD ["/entrypoint.sh"]