variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create infrastructure"
}
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
variable "email" {
  type = string
}
variable "rancher_url" {
  type = string
}
variable "rancher_access_key" {
  type = string
}
variable "rancher_secret_key" {
  type = string
}
variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "bhofmann"
}