#!/bin/bash
if [ ! -f .env.dockerdev ]; then
    echo "File .env.dockerdev not found! Creating an empty file."
    echo "Please set the secrets as per described in .env.dockerdev.example. Otherwise some tests will be skipped."
    touch .env.dockerdev
fi
source bash-utils.sh
script_args $@
# Fetch variables from .env.test so it is used in the docker-compose files
export-dotenv .env.test HASURA_GRAPHQL_ADMIN_SECRET
export-dotenv .env.test JWT_KEY
# Load the variables required for the Minio service
export-dotenv .env.test S3_SECRET_ACCESS_KEY
export-dotenv .env.test S3_ACCESS_KEY_ID
# Use another internal port (4000) to run the dev server so Puppeteer Jest can use the default port (3000) in the local docker context
export PORT=4000

# Start docker services
docker-compose -p hbp_dev -f docker-compose.yaml -f docker-compose.dev.yaml up -d $build
wait-for http://localhost:8080/healthz "Hasura Graphql Engine"
# Set the Hasura config.yaml file
printf 'endpoint: http://localhost:8080\nHASURA_GRAPHQL_ADMIN_SECRET: %s\n' $HASURA_GRAPHQL_ADMIN_SECRET > config.yaml
# Run the Hasura console in a detached process, that will we terminated later
# NOTE: The Hasura console should accessed from the CLI so the migration files can be automatically generated
hasura console &
console_pid=$!
# Run Jest on watch mode
docker exec -it -e PORT=3000 -e NODE_ENV=test hbp_dev_hasura-backend-plus_1 yarn test:watch
# Terminate the Hasura console
kill -TERM $console_pid
# Stop and remove all docker images, volumes and networks
docker-compose -p hbp_dev down -v --remove-orphans
