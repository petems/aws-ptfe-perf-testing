provider "tfe" {
variable "oauth_token_id" {
  type = "string"
}

resource "tfe_organization" "5mb_organisation" {
  name = "5mb-org-testing"
  email = "psouter@hashicorp.com"
}

# Use this to get the oauth-id, comment out afterwards
# resource "tfe_workspace" "foo" {
#   name          = "foo"
#   organization  = "${tfe_organization.5mb_organisation.name}"

#  # vcs_repo {
#  #   identifier     = "petems/arbitary-terraform-code"
#  #   oauth_token_id = "ot-dknb8WkWRsHg1q4p"
#  #   branch         = "master"
#  # }
# }


resource "tfe_workspace" "5mb_workspace" {
  name          = "5mb-workspace-${count.index}"
  organization  = "${tfe_organization.5mb_organisation.name}"
  count         = 500

  vcs_repo {
    identifier     = "petems/arbitary-terraform-code"
    # https://github.com/terraform-providers/terraform-provider-tfe/issues/10 will help here! :)
    oauth_token_id = "${var.oauth_token_id}" #
    branch         = "master"
  }
}

output "ids_of_all_workspaces" {
  value = ["${tfe_workspace.5mb_workspace.*.external_id}"]
}
