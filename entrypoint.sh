#!/bin/sh

set -e

echo "=== INICIANDO ENTRYPOINT PARA EVOLUTION API ==="
echo "Verificando variáveis de ambiente..."

# Configuração de log para depuração
env | grep -v PASSWORD | grep -v SECRET | grep -v KEY | sort

# Verifica e configura variáveis de memória do Node.js
export NODE_OPTIONS="--max-old-space-size=512"
echo "NODE_OPTIONS configurado: $NODE_OPTIONS"

# Verificação de diretórios
echo "Verificando diretórios..."
ls -la /evolution || echo "Diretório /evolution não encontrado!"
mkdir -p /evolution/instances
chmod -R 777 /evolution/instances
echo "Diretório de instâncias criado e permissões definidas"

# Verifica se a variável PORT está definida e a configura para o Evolution API
if [ -n "${PORT+x}" ]; then
  export SERVER_PORT="$PORT"
  echo "Evolution API iniciará na porta '$PORT'"
else
  echo "Variável PORT não definida, usando valor padrão"
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
  export DATABASE_CONNECTION_URI="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_DATABASE?ssl=true"
  echo "PostgreSQL configurado: $DATABASE_PROVIDER://$DB_HOST:$DB_PORT/$DB_DATABASE"
else
  echo "AVISO: DATABASE_URL não definida!"
fi

# Configuração do Redis
if [ -n "${REDIS_URL+x}" ]; then
  echo "Configurando conexão Redis a partir de REDIS_URL"
  export CACHE_REDIS_ENABLED=true
  export CACHE_REDIS_URI="$REDIS_URL"
  echo "Redis configurado: $REDIS_URL"
else
  echo "AVISO: REDIS_URL não definida!"
fi

# Verificar se os arquivos executáveis existem
echo "Verificando estrutura de arquivos..."
if [ -f "/evolution/dist/src/main.js" ]; then
  echo "Arquivo main.js encontrado"
else
  echo "ERRO: Arquivo /evolution/dist/src/main.js não encontrado!"
  find /evolution -type f -name "*.js" | grep main || echo "Nenhum arquivo main.js encontrado"
  ls -la /evolution/dist || echo "Diretório dist não existe"
  ls -la /evolution/dist/src || echo "Diretório dist/src não existe"
fi

# Inicia a Evolution API com mais logs
echo "=== INICIANDO EVOLUTION API ==="
cd /evolution
set -x  # Imprimir comandos enquanto são executados
node --trace-warnings --trace-gc /evolution/dist/src/main.js