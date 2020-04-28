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

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "eu-central-1"
}

variable "digitalocean_token" {
  type = string
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "bhofmann"
}

variable "email" {
  type = string
}
variable "rancher_admin_password" {
  type = string
}
variable "rancher_subdomain" {
  type = string
}

variable "instance_type" {
  type        = string
  description = "Instance type used for all EC2 instances"
  default     = "t3a.medium"
}

variable "docker_version" {
  type        = string
  description = "Docker version to install on nodes"
  default     = "19.03"
}

# Number of nodes to create for the first cluster
variable "rancher_server_cluster_nodes" {
  default = 3
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
