terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

# Somre resources required to be in us-east-1,
# use an aliased providers so we can be specific.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "github" {
  token = var.github_token
  owner = var.github_organization
}
