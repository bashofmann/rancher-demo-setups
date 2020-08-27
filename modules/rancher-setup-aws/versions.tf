terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    rancher2 = {
      source = "terraform-providers/rancher2"
    }
  }
  required_version = ">= 0.13"
}
