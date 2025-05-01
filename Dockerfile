FROM node:20-bullseye

WORKDIR /evolution

# Instalação de dependências essenciais
RUN apt-get update && \
    apt-get install -y git tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clonar o repositório da Evolution API
RUN git clone https://github.com/EvolutionAPI/evolution-api.git /evolution

# Instalar dependências
RUN npm install -g npm@latest
RUN npm install

# Gerar o Prisma Client
RUN npx prisma generate

# Compilar a aplicação
RUN npm run build

# Criar diretório para instâncias
RUN mkdir -p /evolution/instances && \
    chmod -R 777 /evolution/instances

# Cópia do script de entrypoint
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Configuração de variáveis de ambiente
ENV NODE_ENV=production
ENV SERVER_TYPE=http
ENV DATABASE_ENABLED=true
ENV DATABASE_PROVIDER=postgresql
ENV CACHE_REDIS_ENABLED=true
ENV NODE_OPTIONS="--max-old-space-size=1024"

CMD ["/entrypoint.sh"]