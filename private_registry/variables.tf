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

# Required
variable "digitalocean_token" {
  type        = string
  description = "API token for DigitalOcean"
}

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "eu-central-1"
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "bhofmann"
}

variable "instance_type" {
  type        = string
  description = "Instance type used for all EC2 instances"
  default     = "t3a.medium"
}

variable "ssh_key_file_name" {
  type        = string
  description = "File path and name of SSH private key used for infrastructure and RKE"
  default     = "~/.ssh/id_rsa"
}


# Local variables used to reduce repetition
locals {
  node_username = "ubuntu"
}
