#!/bin/sh

# Verifica se a variável PORT está definida e a configura para o Evolution API
if [ -n "${PORT+x}" ]; then
  export SERVER_PORT="$PORT"
  echo "Evolution API iniciará na porta '$PORT'"
fi

# Função para processar URLs
parse_url() {
  eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
}

# Configuração do PostgreSQL
if [ -n "${DATABASE_URL+x}" ]; then
  echo "Configurando conexão PostgreSQL a partir de DATABASE_URL"
  # Prefixo de variáveis para evitar conflitos
  PREFIX="DB_" parse_url "$DATABASE_URL"
  
  # Separa host e porta
  DB_HOST="$(echo $DB_HOSTPORT | sed -e 's,:.*,,g')"
  DB_PORT="$(echo $DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

  # Configura variáveis de ambiente para o PostgreSQL
  export DATABASE_PROVIDER=postgresql
  export DATABASE_CONNECTION_URI="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_DATABASE"
  echo "PostgreSQL configurado: $DATABASE_PROVIDER://$DB_HOST:$DB_PORT/$DB_DATABASE"
fi

# Configuração do Redis
if [ -n "${REDIS_URL+x}" ]; then
  echo "Configurando conexão Redis a partir de REDIS_URL"
  export CACHE_REDIS_ENABLED=true
  export CACHE_REDIS_URI="$REDIS_URL"
  echo "Redis configurado: $REDIS_URL"
fi

# Diretório para armazenar as instâncias
mkdir -p /evolution/instances
echo "Diretório de instâncias criado"

# Inicia a Evolution API
echo "Iniciando Evolution API..."
exec node dist/src/main.js