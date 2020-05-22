resource "rancher2_cloud_credential" "aws" {
  name = "${var.prefix}-aws"

  amazonec2_credential_config {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
  }
}

resource "rancher2_node_template" "controlplane" {
  name        = "${var.prefix}-aws-controlplane"
  description = "Template for control plane nodes"

  cloud_credential_id = rancher2_cloud_credential.aws.id

  amazonec2_config {
    ami                  = var.aws_ami
    region               = var.aws_region
    security_group       = [var.aws_security_group]
    subnet_id            = var.aws_subnet_id
    vpc_id               = var.aws_vpc_id
    zone                 = var.aws_zone
    root_size            = "10"
    instance_type        = "t3a.medium"
    iam_instance_profile = "RancherK8SUnrestrictedCloudProviderRoleEU"
  }
}

resource "rancher2_node_template" "worker" {
  name        = "${var.prefix}-aws-worker"
  description = "Template for worker nodes"

  cloud_credential_id = rancher2_cloud_credential.aws.id

  amazonec2_config {
    ami                  = var.aws_ami
    region               = var.aws_region
    security_group       = [var.aws_security_group]
    subnet_id            = var.aws_subnet_id
    vpc_id               = var.aws_vpc_id
    zone                 = var.aws_zone
    root_size            = "20"
    instance_type        = "t3a.xlarge"
    iam_instance_profile = "RancherK8SUnrestrictedCloudProviderRoleEU"
  }
}
