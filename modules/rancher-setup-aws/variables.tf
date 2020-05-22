variable "rancher_url" {
  type = string
}
variable "rancher_admin_token" {
  type    = string
  default = null
}
variable "rancher_access_key" {
  type    = string
  default = null
}
variable "rancher_secret_key" {
  type    = string
  default = null
}

# Required
variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create infrastructure"
}

# Required
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key used to create AWS infrastructure"
}

/// node template settings
variable "aws_ami" {
}
variable "aws_region" {
}
variable "aws_security_group" {
}
variable "aws_subnet_id" {
}
variable "aws_vpc_id" {
}
variable "aws_zone" {
}
variable "docker_version" {
}
variable "prefix" {
  type    = string
  default = "bhofmann"
}