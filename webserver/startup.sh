#!/bin/sh

CONFIG_FILE="/opt/e-SUS/webserver/config/application.properties"

# Carrega configurações do application.properties se existir
if [ -f "$CONFIG_FILE" ]; then
  while IFS='=' read -r key value; do
    key=$(echo "$key" | xargs | tr '.' '_')
    value=$(echo "$value" | xargs)
    [ -z "$key" ] && continue
    export "${key}"="${value}"
  done < "$CONFIG_FILE"
fi

# Permite sobrescrever por variáveis de ambiente
spring_datasource_url="${APP_DB_URL:-${spring_datasource_url:-}}"
spring_datasource_username="${APP_DB_USER:-${spring_datasource_username:-}}"
spring_datasource_password="${APP_DB_PASSWORD:-${spring_datasource_password:-}}"

echo "Database URL = ${spring_datasource_url}"
echo "Username = ${spring_datasource_username}"

# Primeira execução: instala o e-SUS se necessário
if [ ! -x "/opt/e-SUS/webserver/standalone.sh" ]; then
  echo "Instalação inicial do e-SUS..."
  echo "s" | java -jar /opt/bootstrap/eSUS-AB-PEC.jar -console -url="${spring_datasource_url}" -username="${spring_datasource_username}" -password="${spring_datasource_password}"
fi

# Executa migrador com tentativas
#ATTEMPTS=12
#COUNT=0
#until [ $COUNT -ge $ATTEMPTS ]; do
#  if java -jar /opt/bootstrap/migrador.jar -url="${spring_datasource_url}" -username="${spring_datasource_username}" -password="${spring_datasource_password}"; then
#    break
#  fi
#  COUNT=$((COUNT+1))
#  echo "Falha ao executar o migrador (tentativa ${COUNT}/${ATTEMPTS}). Aguardando 10s..."
#  sleep 10
#done

exec sh /opt/e-SUS/webserver/standalone.sh