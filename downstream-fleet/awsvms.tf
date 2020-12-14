resource "aws_key_pair" "ssh_key_pair" {
  key_name_prefix = "${var.prefix}-rancher-k3s-fleet-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}

# Security group to allow all traffic
resource "aws_security_group" "sg_allowall" {
  name = "${var.prefix}-rancher-k3s-fleet-allowall"

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

resource "aws_instance" "amd_vms" {
  count         = 2
  ami           = data.aws_ami.sles.id
  instance_type = "t3a.medium"

  key_name        = aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.sg_allowall.name]

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

  tags = {
    Name = "${var.prefix}-rancher-k3s-fleet-amd"
  }
}

resource "aws_instance" "arm_vms" {
  count         = 1
  ami           = data.aws_ami.slesarm.id
  instance_type = "a1.medium"

  key_name        = aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.sg_allowall.name]

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

  tags = {
    Name = "${var.prefix}-rancher-k3s-fleet-arm"
  }
}