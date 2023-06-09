#!/usr/bin/env bash
cd "$(dirname "$0")"

API_URL=""
ADMIN_PASSWORD="admin"

TOKEN_JSON=$(curl -H "Content-Type: application/json" -d "{\"password\":{\"username\":\"admin\",\"password\":\"${ADMIN_PASSWORD}\"}}" "${API_URL}/v1/auth")
TOKEN=$(echo ${TOKEN_JSON} | jq -r '.token.token')

curl -k -H "Content-Type: application/json" -H "X-Auth-Token: $TOKEN" "${API_URL}/v1/scan/scanner"

# Get all federated clusters
joint_cluster_ids=$(curl -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -X GET "${API_URL}/v1/fed/member" | jq -r '.joint_clusters[].id')

# For each cluster get a list of workloads including a scan summery
for id in $joint_cluster_ids; do
  curl -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -X GET "${API_URL}/v1/fed/cluster/${id}/v1/workload?view=pod" --compressed | jq '.'
done

# Log out
curl -s -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -X DELETE "${API_URL}/v1/auth"
