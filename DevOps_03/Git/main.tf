provider "github" {
  token = ""
  owner = "kreeptos"
}

resource "github_repository" "example" {
  auto_init   = true
  name        = "example"
  description = "My awesome codebase"
}

resource "github_branch" "development" {
  repository = "example"
  branch     = "develop"
  depends_on = [github_repository.example]

}

resource "github_branch_protection" "example" {
  repository_id  = github_repository.example.node_id
  pattern        = "main"
  enforce_admins =  true

   required_status_checks {
    strict   = false
    
  }

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    dismissal_restrictions = []
  }
}

resource "github_user_ssh_key" "example" {
  title = "example title"
  key   = "${file("~/.ssh/id_rsa.pub")}"
}
