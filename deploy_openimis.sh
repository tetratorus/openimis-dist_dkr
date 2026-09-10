#!/bin/bash

# Print a random alphanumeric secret (safe to embed in URLs such as CACHE_URL)
gen_secret() {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
}

# Set VAR=value in .env if VAR is currently empty or missing
set_if_empty() {
  local var="$1" value="$2"
  if grep -Eq "^${var}=.+" .env; then
    return
  fi
  if grep -Eq "^${var}=" .env; then
    sed -i.bak "s|^${var}=.*|${var}=${value}|" .env && rm -f .env.bak
  else
    echo "${var}=${value}" >> .env
  fi
  echo "generated a random ${var} in .env"
}

#rename .env
if [[ -f '.env' ]]
then
echo "Using existing env files"
else
echo "creating env files from example"
cp .env.example .env
cp .env.openSearch.example .env.openSearch
fi

# Never run the datastores with empty or shared default credentials
set_if_empty DB_PASSWORD "$(gen_secret)"
set_if_empty REDIS_PASSWORD "$(gen_secret)"


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


