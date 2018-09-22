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
          "id": "$1"
        }
      }
    }
  }
}
EOF
)

echo $RES | jq
}

workspace_ids=$(terraform output ids_of_all_workspaces | sed -e 's/,/\n/g')

echo "Triggering 1-500"

for X in $workspace_ids
do
  trigger_run $X
done
