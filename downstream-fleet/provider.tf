terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.10.6"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  alias      = "aws_eu_west"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "eu-west-1"
}

provider "aws" {
  alias      = "aws_eu_central"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "eu-central-1"
}

provider "rancher2" {
  api_url    = var.rancher_url
  insecure   = true
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}