resource "aws_key_pair" "ssh_key_pair_central" {
  provider        = aws.aws_eu_central
  key_name_prefix = "${var.prefix}-rancher-k3s-fleet-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}
resource "aws_key_pair" "ssh_key_pair_west" {
  provider        = aws.aws_eu_west
  key_name_prefix = "${var.prefix}-rancher-k3s-fleet-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}

# Security group to allow all traffic
resource "aws_security_group" "sg_allowall_central" {
  provider = aws.aws_eu_central
  name     = "${var.prefix}-rancher-k3s-fleet-allowall"

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
resource "aws_security_group" "sg_allowall_west" {
  provider = aws.aws_eu_west
  name     = "${var.prefix}-rancher-k3s-fleet-allowall"

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

resource "aws_instance" "cluster_one" {
  provider      = aws.aws_eu_central
  ami           = data.aws_ami.sles_central.id
  instance_type = "t3a.medium"

  key_name        = aws_key_pair.ssh_key_pair_central.key_name
  security_groups = [aws_security_group.sg_allowall_central.name]

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
    Name = "${var.prefix}-rancher-k3s-fleet-one"
  }
}

resource "aws_instance" "cluster_two" {
  provider      = aws.aws_eu_west
  ami           = data.aws_ami.sles_west.id
  instance_type = "t3a.medium"

  key_name        = aws_key_pair.ssh_key_pair_west.key_name
  security_groups = [aws_security_group.sg_allowall_west.name]

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
    Name = "${var.prefix}-rancher-k3s-fleet-two"
  }
}

resource "aws_instance" "cluster_three" {
  provider      = aws.aws_eu_central
  ami           = data.aws_ami.sles_arm_central.id
  instance_type = "a1.medium"

  key_name        = aws_key_pair.ssh_key_pair_central.key_name
  security_groups = [aws_security_group.sg_allowall_central.name]

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
    Name = "${var.prefix}-rancher-k3s-fleet-three"
  }
}

resource "aws_instance" "cluster_four" {
  provider      = aws.aws_eu_west
  ami           = data.aws_ami.sles_arm_west.id
  instance_type = "a1.medium"

  key_name        = aws_key_pair.ssh_key_pair_west.key_name
  security_groups = [aws_security_group.sg_allowall_west.name]

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
    Name = "${var.prefix}-rancher-k3s-fleet-four"
  }
}