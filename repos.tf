resource "github_repository" "repo_blog_template" {
  name                        = "blog_template"
  description                 = "Base template for blog repository."
  is_template                 = true
  visibility                  = "private"
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "COMMIT_MESSAGES"
  delete_branch_on_merge      = true
  allow_update_branch         = true
  has_issues                  = true
}

resource "github_repository" "repo_infrastructure" {
  name        = "infrastructure"
  description = "Terraform infra-as-code for the blog."

  template {
    owner      = var.github_organization
    repository = github_repository.repo_blog_template.name
  }
}
