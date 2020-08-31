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
}

#TODO: Find a secure way to generate this key
resource "tls_private_key" "bootstrap_tls_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "local_file" "git_private_key_pem" {
  sensitive_content = tls_private_key.bootstrap_tls_key.private_key_pem
  filename = "${path.cwd}/../git.pem"
}

resource "github_repository_deploy_key" "bootstrap_write_key" {
  key = tls_private_key.bootstrap_tls_key.public_key_openssh
  repository = github_repository.bootstrap_repository.name
  title = "Bootstrap write deploy key"
  read_only  = "false"
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
    GIT_PEM_B64_KEYFILE_CONTENT=base64encode(tls_private_key.bootstrap_tls_key.private_key_pem)
  }
}

### Other repositories resources ###

resource "github_repository" "github_repositories" {
  for_each = toset(var.github_repos)

  name = each.key
  delete_branch_on_merge = true
  private = var.github_repos_private
  auto_init = true
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
}
