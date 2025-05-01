FROM node:18-alpine

WORKDIR /evolution

# Instalação de dependências essenciais
RUN apk add --no-cache git tzdata

# Clonar o repositório da Evolution API
RUN git clone https://github.com/EvolutionAPI/evolution-api.git /evolution

# Instalar dependências
RUN npm install pm2 -g
RUN npm install

# Configuração de variáveis de ambiente padrão
ENV NODE_ENV=production
ENV SERVER_TYPE=http
ENV DATABASE_ENABLED=true
ENV DATABASE_PROVIDER=postgresql
ENV CACHE_REDIS_ENABLED=true

# Compilar a aplicação
RUN npm run build

# Criar diretório para instâncias
RUN mkdir -p /evolution/instances && \
    chmod -R 777 /evolution/instances

# Cópia do script de entrypoint
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]