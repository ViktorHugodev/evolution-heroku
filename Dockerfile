FROM atendai/evolution-api:latest

USER root

WORKDIR /evolution

# Instalação de ferramentas de diagnóstico
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    procps \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Verificação do ambiente e estrutura de diretórios
RUN mkdir -p /evolution/instances && \
    chmod -R 777 /evolution/instances

# Cópia e configuração do script de entrypoint
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Configuração de variáveis de ambiente padrão
ENV NODE_ENV=production
ENV SERVER_TYPE=http
ENV DATABASE_ENABLED=true
ENV DATABASE_PROVIDER=postgresql
ENV CACHE_REDIS_ENABLED=true
ENV NODE_OPTIONS="--max-old-space-size=512"

# Define o comando de inicialização
CMD ["/entrypoint.sh"]