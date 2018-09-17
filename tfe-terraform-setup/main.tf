provider "tfe" {
}

resource "tfe_organization" "5mb_organisation" {
  name = "5mb-org-testing"
  email = "psouter@hashicorp.com"
}

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

# Not possible to get workspace IDs yet: https://github.com/terraform-providers/terraform-provider-tfe/issues/19
# output "ids_of_all_workspaces" {
#   value = ["${tfe_workspace.5mb_workspace.*.id}"]
# }
