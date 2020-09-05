variable "circleci_personal_token" {
  type = string
}

variable "github_personal_token" {
  type = string
}

variable "github_organization_name" {
  type = string
}

provider "github" {
  token        = var.github_personal_token
  organization = var.github_organization_name

  version = "~> 2.9"
}

provider "circleci" {
  token    = var.circleci_personal_token
  organization = var.github_organization_name
}

data "google_organization" "organisation" {
  organization = var.org_id
}

module "github_circleci_bootstrap" {
  source = "./modules/github-circleci-bootstrap"

  github_bootstrap_repo = "${data.google_organization.organisation.domain}-0-bootstrap"

  github_repos = [
    "${data.google_organization.organisation.domain}-1-org",
    "${data.google_organization.organisation.domain}-2-environments",
    "${data.google_organization.organisation.domain}-3-networks",
    "${data.google_organization.organisation.domain}-4-projects",
  ]

  terraform_sa_name = module.seed_bootstrap.terraform_sa_name
  seed_project_id = module.seed_bootstrap.seed_project_id

  google_default_region = var.default_region
  google_iam_group_billing_admin = var.group_billing_admins
  google_iam_group_org_admin = var.group_org_admins
  circleci_personal_token = var.circleci_personal_token
  github_organization_name = var.github_organization_name
  github_personal_token = var.github_personal_token
}

output "github_repositories" {
  value = module.github_circleci_bootstrap.github_repositories
}

output "git_pem_keyfile_path" {
  value = module.github_circleci_bootstrap.git_pem_keyfile_path
}

output "gcp_organisation_domain" {
  value = data.google_organization.organisation.domain
}