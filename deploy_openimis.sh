#!/bin/bash
#rename .env
if [[ -f '.env' ]]
then
echo "Using existing env files"
else
echo "creating env files from example"
cp .env.example .env
cp .env.openSearch.example .env.openSearch
# no database password is shipped in .env.example, generate one per deployment
# the aA1@ suffix guarantees the MSSQL password complexity requirements
sed -i "s/^DB_PASSWORD=$/DB_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=')aA1@/" .env
sed -i "s/^DB_SA_PASSWORD=$/DB_SA_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=')aA1@/" .env
echo "generated database passwords in .env"
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


