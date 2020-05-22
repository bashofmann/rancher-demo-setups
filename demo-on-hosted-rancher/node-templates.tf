module "rancher-setup" {
  source             = "../modules/rancher-setup-aws"
  rancher_url        = var.rancher_url
  rancher_access_key = var.rancher_access_key
  rancher_secret_key = var.rancher_secret_key
  aws_access_key     = var.aws_access_key
  aws_secret_key     = var.aws_secret_key
  aws_ami            = data.aws_ami.ubuntu.id
  aws_region         = var.aws_region
  aws_security_group = aws_security_group.rancher_sg_allowall.name
  aws_subnet_id      = ""
  aws_vpc_id         = ""
  aws_zone           = "a"
  docker_version     = var.docker_version
}