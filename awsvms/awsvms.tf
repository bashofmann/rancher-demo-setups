# AWS infrastructure resources

# Temporary key pair used for SSH accesss
resource "aws_key_pair" "quickstart_key_pair" {
  key_name_prefix = "${var.prefix}-k3s-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}

// TODO more
# Security group to allow all traffic
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
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name        = aws_key_pair.quickstart_key_pair.key_name
  security_groups = [aws_security_group.rancher_sg_allowall.name]

  tags = {
    Name        = "${var.prefix}-rc-${count.index}"
    Owner       = "bhofmann"
    DoNotDelete = "true"
  }

  user_data = templatefile("../userdata/server.sh", {
    docker_version = "19.03"
    username       = local.node_username
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
      user        = local.node_username
      private_key = file(var.ssh_key_file_name)
    }
  }
}

resource "aws_instance" "downstream-cluster" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name        = aws_key_pair.quickstart_key_pair.key_name
  security_groups = [aws_security_group.rancher_sg_allowall.name]

  tags = {
    Name        = "${var.prefix}-ds-${count.index}"
    Owner       = "bhofmann"
    DoNotDelete = "true"
  }

  user_data = templatefile("../userdata/server.sh", {
    docker_version = "19.03"
    username       = local.node_username
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
      user        = local.node_username
      private_key = file(var.ssh_key_file_name)
    }
  }
}
