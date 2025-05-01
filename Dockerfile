FROM atendai/evolution-api:latest

# Instalar ferramentas de diagnóstico
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    procps \
    lsof \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório de trabalho
WORKDIR /evolution

# Copiar entrypoint.sh para o container
COPY entrypoint.sh /evolution/entrypoint.sh

# Configurar permissões de execução
RUN chmod +x /evolution/entrypoint.sh

# Criar diretório de logs se não existir
RUN mkdir -p /evolution/logs

# Expor a porta que será usada
EXPOSE 8080

# Verificar a estrutura da imagem para debug
RUN echo "Estrutura da imagem:" && \
    find / -name "*.js" | grep -E 'main|server|app|index' || echo "Nenhum arquivo principal encontrado"

# Definir volume para persistência
VOLUME ["/evolution/instances", "/evolution/logs"]

# Executar o script de entrada
ENTRYPOINT ["/evolution/entrypoint.sh"]