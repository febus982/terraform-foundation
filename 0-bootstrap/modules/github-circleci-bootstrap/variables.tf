variable "github_bootstrap_repo" {
  description = "Bootstrap GitHub Repo to create with CircleCI triggers."
  type        = string
}

variable "github_repos" {
  description = "List of GitHub Repos to create with CircleCI triggers."
  type        = list(string)
}

variable "github_repos_private" {
  description = "Create private repositories"
  type        = bool

  default = false
}

variable "terraform_sa_name" {
  description = "Fully qualified name for privileged service account for Terraform."
  type        = string
}

variable "seed_project_id" {
  description = "Project where terraform service accounts is enabled."
  type        = string
}

variable "google_default_region" {
  type        = string
}

variable "google_iam_group_billing_admin" {
  type        = string
}

variable "google_iam_group_org_admin" {
  type        = string
}

variable "circleci_personal_token" {
  type = string
}

variable "github_personal_token" {
  type = string
}

variable "github_organization_name" {
  type = string
}

