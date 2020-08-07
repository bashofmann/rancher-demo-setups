resource "aws_key_pair" "ssh_key_pair" {
  key_name_prefix = "bhofmann-ssh-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}