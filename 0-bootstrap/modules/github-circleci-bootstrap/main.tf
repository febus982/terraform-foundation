data "google_project" "seed_project" {
  project_id = var.seed_project_id
}

resource "google_service_account_key" "terraform_sa_key" {
  service_account_id = var.terraform_sa_name
}

### Bootstrap resources ###

resource "github_repository" "bootstrap_repository" {
  name = var.github_bootstrap_repo
  delete_branch_on_merge = true
  private = var.github_repos_private
  auto_init = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "circleci_project" "circleci_bootstrap_project" {
  depends_on = [github_repository.bootstrap_repository]
  name       = github_repository.bootstrap_repository.name

  env_vars = {
    GOOGLE_CREDENTIALS=base64decode(google_service_account_key.terraform_sa_key.private_key)
    GOOGLE_ORGANIZATION_ID=data.google_project.seed_project.org_id
    GOOGLE_BILLING_ACCOUNT_ID=data.google_project.seed_project.billing_account
    GOOGLE_DEFAULT_REGION=var.google_default_region
    GOOGLE_IAM_GROUP_ORG_ADMIN=var.google_iam_group_org_admin
    GOOGLE_IAM_GROUP_BILLING_ADMIN=var.google_iam_group_billing_admin
    GITHUB_PERSONAL_TOKEN=var.github_personal_token
    GITHUB_ORGANIZATION_NAME=var.github_organization_name
    CIRCLECI_PERSONAL_TOKEN=var.github_personal_token
  }

  lifecycle {
    prevent_destroy = true
  }
}

### Other repositories resources ###

resource "github_repository" "github_repositories" {
  for_each = toset(var.github_repos)

  name = each.key
  delete_branch_on_merge = true
  private = var.github_repos_private
  auto_init = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "circleci_project" "circleci_projects" {
  depends_on = [github_repository.github_repositories]
  for_each   = github_repository.github_repositories
  name       = each.value.name

  env_vars = {
    GOOGLE_CREDENTIALS=base64decode(google_service_account_key.terraform_sa_key.private_key)
    GOOGLE_ORGANIZATION_ID=data.google_project.seed_project.org_id
    GOOGLE_BILLING_ACCOUNT_ID=data.google_project.seed_project.billing_account
    GOOGLE_DEFAULT_REGION=var.google_default_region
    GOOGLE_IAM_GROUP_ORG_ADMIN=var.google_iam_group_org_admin
    GOOGLE_IAM_GROUP_BILLING_ADMIN=var.google_iam_group_billing_admin
  }

  lifecycle {
    prevent_destroy = true
  }
}
