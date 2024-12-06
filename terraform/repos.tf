resource "github_repository" "repo_blog_template" {
  name                        = "blog_template"
  description                 = "Base template for blog repository."
  is_template                 = true
  visibility                  = "private"
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "COMMIT_MESSAGES"
  delete_branch_on_merge      = true
  allow_update_branch         = true
  allow_auto_merge            = true
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.repo_blog_template.id
  pattern       = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews = true
  }

  required_status_checks {
    strict = true
  }

  enforce_admins = true
}

resource "github_repository" "repo_infrastructure" {
  name        = "infrastructure"
  description = "Terraform infra-as-code for the blog."

  template {
    owner      = var.github_organization
    repository = github_repository.repo_blog_template.name
  }
}
