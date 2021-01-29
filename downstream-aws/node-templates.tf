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
  engine_install_url  = "https://releases.rancher.com/install-docker/${var.docker_version}.sh"

  amazonec2_config {
    ami                  = data.aws_ami.ubuntu.id
    region               = var.aws_region
    security_group       = [aws_security_group.rancher_sg_allowall.name]
    subnet_id            = ""
    vpc_id               = ""
    zone                 = "a"
    root_size            = "10"
    instance_type        = "t3a.medium"
    iam_instance_profile = aws_iam_instance_profile.rke_profile.name
  }
}

resource "rancher2_node_template" "worker" {
  name        = "${var.prefix}-aws-worker"
  description = "Template for worker nodes"

  cloud_credential_id = rancher2_cloud_credential.aws.id
  engine_install_url  = "https://releases.rancher.com/install-docker/${var.docker_version}.sh"

  amazonec2_config {
    ami                  = data.aws_ami.ubuntu.id
    region               = var.aws_region
    security_group       = [aws_security_group.rancher_sg_allowall.name]
    subnet_id            = ""
    vpc_id               = ""
    zone                 = "a"
    root_size            = "20"
    instance_type        = "t3a.xlarge"
    iam_instance_profile = aws_iam_instance_profile.rke_profile.name
  }
}
