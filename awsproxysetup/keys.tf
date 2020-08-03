resource "aws_key_pair" "quickstart_key_pair" {
  key_name_prefix = "bhofmann-rancher-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}