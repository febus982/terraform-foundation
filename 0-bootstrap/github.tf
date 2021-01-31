/* ----------------------------------------
    Requirements
   ---------------------------------------- */

terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = ">=4.3.0, !=4.3.1"
    }
  }
}

/* ----------------------------------------
    Variables & locals
   ---------------------------------------- */

variable "github_personal_token" {
  type = string
}

variable "github_owner" {
  type    = string
  default = "febus982"
}

variable "github_organisation" {
  type = string
  default = ""
}
/* ----------------------------------------
    Provider & data
   ---------------------------------------- */

provider "github" {
  token        = var.github_personal_token
  owner        = var.github_owner
  organization = var.github_organisation
}
