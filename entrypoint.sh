#!/bin/sh

# Verificar se a variável PORT está definida ou usar o padrão
if [ -z ${PORT+x} ]; then echo "Variável PORT não definida, usando porta padrão da Evolution API."; else export SERVER_PORT="$PORT"; echo "Evolution API iniciará na porta '$PORT'"; fi

# Função para analisar URL de banco de dados
parse_url() {
  eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
}

# Configurar PostgreSQL
if [ -n "$DATABASE_URL" ]; then
  # Adicionar prefixo às variáveis para evitar conflitos e executar a função de análise de URL no argumento
  PREFIX="DB_" parse_url "$DATABASE_URL"
  
  # Separar host e porta
  DB_HOST="$(echo $DB_HOSTPORT | sed -e 's,:.*,,g')"
  DB_PORT="$(echo $DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

  # Exportar variáveis para o PostgreSQL
  export DATABASE_PROVIDER=postgresql
  export DATABASE_CONNECTION_URI="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_DATABASE?schema=public"
  echo "Configuração do PostgreSQL definida com DATABASE_URL"
fi

# Configurar Redis
if [ -n "$REDIS_URL" ]; then
  export CACHE_REDIS_ENABLED=true
  export CACHE_REDIS_URI="$REDIS_URL"
  echo "Configuração do Redis definida com REDIS_URL"
fi

# Iniciar a aplicação
exec node dist/src/main.js