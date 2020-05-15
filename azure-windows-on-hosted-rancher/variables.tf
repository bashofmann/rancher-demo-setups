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
variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription id under which resources will be provisioned"
}

variable "azure_client_id" {
  type        = string
  description = "Azure client id used to create resources"
}

variable "azure_client_secret" {
  type        = string
  description = "Client secret used to authenticate with Azure apis"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant id used to create resources"
}

variable "azure_location" {
  type        = string
  description = "Azure location used for all resources"
  default     = "East US"
}
variable "admin_password" {
  type = string
}
variable "prefix" {
  type    = string
  default = "bhofmann"
}
variable "ssh_key_file_name" {
  type        = string
  description = "File path and name of SSH private key used for infrastructure and RKE"
  default     = "~/.ssh/id_rsa"
}
variable "docker_version" {
  type        = string
  description = "Docker version to install on nodes"
  default     = "19.03"
}