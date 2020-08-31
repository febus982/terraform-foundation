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
