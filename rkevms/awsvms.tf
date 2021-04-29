resource "aws_key_pair" "quickstart_key_pair" {
  key_name_prefix = "${var.prefix}-k3s-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}

resource "aws_security_group" "rancher_sg_allowall" {
  name        = "${var.prefix}-aws-allowall"
  description = "Rancher quickstart - allow all traffic"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "rancher-cluster" {
  count         = 3
  ami           = data.aws_ami.rhel.id
  instance_type = var.instance_type

  key_name        = aws_key_pair.quickstart_key_pair.key_name
  security_groups = [aws_security_group.rancher_sg_allowall.name]

  tags = {
    Name        = "${var.prefix}-rc-${count.index}"
    Owner       = "bhofmann"
    DoNotDelete = "true"
  }

  user_data = templatefile("../userdata/server.sh", {
    docker_version = "20.10"
    username       = "ec2-user"
  })

  root_block_device {
    volume_size = 80
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file(var.ssh_key_file_name)
    }
  }
}
