data "terraform_remote_state" "common" {
  backend   = "local"
  workspace = "common"
}

data "terraform_remote_state" "system" {
  backend   = "local"
  workspace = "system"
}

