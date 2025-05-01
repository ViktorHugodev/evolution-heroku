FROM atendai/evolution-api:latest

# Criar diretório de trabalho
WORKDIR /evolution

# Copiar arquivos de configuração
COPY entrypoint.sh /evolution/entrypoint.sh

# Configurar permissões de execução
RUN chmod +x /evolution/entrypoint.sh

# Expor a porta que será usada
EXPOSE 8080

# Definir volume para persistência
VOLUME ["/evolution/instances"]

# Executar o script de entrada
ENTRYPOINT ["/evolution/entrypoint.sh"]