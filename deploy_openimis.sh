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

# generate a random secret for any password left empty in .env
generate_secret() {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
}

for secret_var in DB_PASSWORD REDIS_PASSWORD SECRET_KEY
do
  if grep -Eq "^${secret_var}=\s*$" .env
  then
    echo "${secret_var} is empty in .env, generating a random value"
    generated=$(generate_secret)
    sed -i "s|^${secret_var}=.*$|${secret_var}=${generated}|" .env
  fi
done

for secret_var in DB_PASSWORD REDIS_PASSWORD SECRET_KEY
do
  if ! grep -Eq "^${secret_var}=.+$" .env
  then
    echo "ERROR: ${secret_var} must be set to a non-empty value in .env" >&2
    exit 1
  fi
done


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


