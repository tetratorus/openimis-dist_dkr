#!/bin/bash
#rename .env
if [[ -f '.env' ]]
then
echo "Using existing env files"
else
echo "creating env files from example"
cp .env.example .env
cp .env.openSearch.example .env.openSearch
fi

# generate strong random database passwords if they are not set
gen_password() {
  # 32 alphanumeric chars plus a symbol group to satisfy MSSQL complexity policy
  echo "$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)Aa1!"
}
ensure_env_password() {
  local key="$1"
  if grep -qE "^${key}=.+" .env
  then
    return
  fi
  local value
  value="$(gen_password)"
  if grep -qE "^${key}=" .env
  then
    sed -i "s|^${key}=.*|${key}=${value}|" .env
  else
    echo "${key}=${value}" >> .env
  fi
  echo "generated random ${key} in .env"
}
ensure_env_password DB_PASSWORD
ensure_env_password DB_SA_PASSWORD


if [[ -f '.init.lock' ]]
then
echo "initialisation already done"
else
echo "initialisation"

docker compose  up -d db
# #set -a # automatically export all variables
# source .env
# source .env.lightning
# #set +a
# docker compose  run -e  PGPASSWORD=${POSTGRES_PASSWORD} --rm db createdb -h db -U ${POSTGRES_USER}  ${POSTGRES_DB}
# set -e
# docker compose  run --rm  web mix ecto.migrate
# docker compose  run --rm web mix run imisSetupScripts/imisSetup.exs
# #TODO init OpenSearch dashboard with API/ manage command
echo "connect to https://{DOMAIN}"
echo "then go to https://{DOMAIN}/opensearch"
echo "then go in manage / saved object / import to import the OpenSearch dashboard"
touch '.init.lock' 
fi
docker compose up -d


