resource "rancher2_cloud_credential" "aws" {
  name = "aws"
  amazonec2_credential_config {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
  }
}

resource "rancher2_cluster" "bhofmann-eks" {
  name        = "bhofmann-eks"
  description = "Terraform EKS cluster"
  eks_config_v2 {
    cloud_credential_id = rancher2_cloud_credential.aws.id
    region              = "eu-central-1"
    kubernetes_version  = "1.21"
    logging_types       = ["audit", "api"]
    node_groups {
      name          = "rancher_node_group"
      instance_type = "m5.xlarge"
      desired_size  = 2
      min_size      = 1
      max_size      = 3
    }
    public_access = true
  }
}
