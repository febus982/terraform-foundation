output "github_repositories" {
  value = merge(
    {
      (github_repository.bootstrap_repository.name): github_repository.bootstrap_repository
    },
    {
      for repo in github_repository.github_repositories:
      repo.name => repo
    }
  )
}

output "git_pem_keyfile_path" {
  value = local_file.git_private_key_pem.filename
}