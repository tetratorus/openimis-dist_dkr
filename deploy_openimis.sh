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

# Never start with an empty/placeholder Redis password: generate a strong random one
if ! grep -Eq '^REDIS_PASSWORD=.+' .env
then
echo "generating REDIS_PASSWORD"
REDIS_PASSWORD_GEN=$(openssl rand -hex 32)
if grep -q '^REDIS_PASSWORD=' .env
then
sed -i.bak "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=${REDIS_PASSWORD_GEN}|" .env && rm -f .env.bak
else
echo "REDIS_PASSWORD=${REDIS_PASSWORD_GEN}" >> .env
fi
fi


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


