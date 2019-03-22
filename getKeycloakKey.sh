#!/usr/bin/env bash
set -e

# Gets keycloak RS256 secret from realm
export KEYCLOAK_URL=${KEYCLOAK_URL:-http://localhost:8080}
export KEYCLOAK_REALM=${KEYCLOAK_REALM:-refdata}
export KEYCLOAK_CERTS_URI=${KEYCLOAK_URL}/auth/realms/${KEYCLOAK_REALM}/protocol/openid-connect/certs
cmd="$@"

COUNTER=60
until [ ${COUNTER} -lt 1 ]
do
    echo "Checking ${KEYCLOAK_CERTS_URI}"
    URL=$(curl ${KEYCLOAK_CERTS_URI} 2>/dev/null)
    CHECK=$(echo "$URL" | jq -c '.[][0]' | sed 's/"/\\"/g')
    if [[ ${CHECK} == *"RS256"* ]];
    then
        echo "Retrieved key"
        echo ${URL} > /tmp/.secret
        export PGRST_JWT_SECRET="@/tmp/.secret"
        exec postgrest /etc/postgrest.conf
        break
    else
        echo "Waiting for keycloak .. ${COUNTER}"
        sleep 10
    fi
let COUNTER-=1
done
