#!/usr/bin/env bash
cd "$(dirname "$0")"

API_URL=https://localhost:10443
ADMIN_PASSWORD="$(sed -n 's/.*Password: \(.*\)/\1/p' license.yaml)"

kubectl port-forward -n neuvector svc/neuvector-svc-controller-api 10443 &
PID=$!

# Wait until port-forwarded finished
sleep 5

# Log in
TOKEN_JSON=$(curl -k -H "Content-Type: application/json" -d "{\"password\":{\"username\":\"admin\",\"password\":\"${ADMIN_PASSWORD}\"}}" "${API_URL}/v1/auth")
TOKEN=$(echo ${TOKEN_JSON} | jq -r '.token.token')

# Accept EULA
curl -s -k -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -d '{"eula":{"accepted":true}}' "${API_URL}/v1/eula"

# Set up Auto-Scan
curl -s -k -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -X PATCH -d '{"config":{"auto_scan":true}}' "${API_URL}/v1/scan/config"

# Log out
curl -s -k -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -X DELETE "${API_URL}/v1/auth"

kill $PID