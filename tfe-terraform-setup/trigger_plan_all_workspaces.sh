#!/bin/bash -x
# If private Terraform Enterprise, change this to your API:
export TFEAPI="https://ptfe.petems.xyz/api/v2"

trigger_run () {
  export RES=$(curl -0 -X POST "$TFEAPI/runs" \
  --header "Authorization: Bearer $TFE_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --data @- << EOF
{
  "data": {
    "attributes": {
      "is-destroy":false,
      "message": "Triggered from Trigger all Shell Script"
    },
    "type":"runs",
    "relationships": {
      "workspace": {
        "data": {
          "type": "workspaces",
          "id": $1
        }
      }
    }
  }
}
EOF
)

echo $RES | jq
}

WORKSPACE_JSON_1=$(curl -0 "$TFEAPI/organizations/5mb-org-testing/workspaces?page%5Bnumber%5D=1&page%5Bsize%5D=150" \
 --header "Authorization: Bearer $TFE_TOKEN" \
 --header "Content-Type: application/vnd.api+json")

WORKSPACE_JSON_2=$(curl -0 "$TFEAPI/organizations/5mb-org-testing/workspaces?page%5Bnumber%5D=2&page%5Bsize%5D=150" \
 --header "Authorization: Bearer $TFE_TOKEN" \
 --header "Content-Type: application/vnd.api+json")

WORKSPACE_JSON_3=$(curl -0 "$TFEAPI/organizations/5mb-org-testing/workspaces?page%5Bnumber%5D=3&page%5Bsize%5D=150" \
 --header "Authorization: Bearer $TFE_TOKEN" \
 --header "Content-Type: application/vnd.api+json")

echo "Triggering 1-150"
ID_BLOCK_1=$(echo $WORKSPACE_JSON_1 | jq ".data[] | .id")

for X in $ID_BLOCK_1
do
  trigger_run $X
done

echo "Triggering 151-300"
ID_BLOCK_2=$(echo $WORKSPACE_JSON_2 | jq ".data[] | .id")

for X in $ID_BLOCK_2
do
  trigger_run $X
done

echo "Triggering 301-500"
ID_BLOCK_3=$(echo $WORKSPACE_JSON_3 | jq ".data[] | .id")

for X in $ID_BLOCK_3
do
  trigger_run $X
done
