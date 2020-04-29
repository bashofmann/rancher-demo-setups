module "rancher-server" {
  source = "../modules/rancher-server"

  nodes                  = aws_instance.rancher_server
  dns_record_type        = "CNAME"
  dns_record_value       = "${aws_elb.rancher-server-lb.dns_name}."
  output_dir             = abspath("${path.module}/out")
  email                  = var.email
  rancher_admin_password = var.rancher_admin_password
  rancher_subdomain      = var.rancher_subdomain
  digitalocean_token     = var.digitalocean_token
}

module "rancher-setup" {
  source              = "../modules/rancher-setup-aws"
  rancher_url         = module.rancher-server.rancher_url
  rancher_admin_token = module.rancher-server.rancher_admin_token
  aws_access_key      = var.aws_access_key
  aws_secret_key      = var.aws_secret_key
  aws_ami             = data.aws_ami.ubuntu.id
  aws_region          = var.aws_region
  aws_security_group  = aws_security_group.rancher_sg_allowall.name
  aws_subnet_id       = ""
  aws_vpc_id          = ""
  aws_zone            = "a"
}