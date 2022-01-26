variable "rancher_url" {
  type = string
}
variable "rancher_access_key" {
  type = string
}
variable "rancher_secret_key" {
  type = string
}
variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create infrastructure"
}
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key used to create AWS infrastructure"
}
