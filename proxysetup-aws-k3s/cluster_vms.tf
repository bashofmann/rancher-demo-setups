resource "aws_security_group" "cluster_vms" {
  name = "bhofmann-vpc-private"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.private_subnet_cidr]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_subnet_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.private_subnet_cidr]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "bhofmann-vpc-private"
  }
}

resource "aws_instance" "cluster_vms" {
  count = 1
  ami   = data.aws_ami.ubuntu.id

  instance_type = "t3a.medium"

  key_name                    = aws_key_pair.ssh_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.cluster_vms.id]
  subnet_id                   = aws_subnet.eu-central-1a-private.id
  associate_public_ip_address = true
  source_dest_check           = false
  private_ip                  = "10.0.1.${count.index + 200}"

  user_data = templatefile("userdata/cluster_vms.sh", {
    proxy_private_ip = aws_instance.proxy.private_ip
  })

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]

    connection {
      type                = "ssh"
      host                = self.private_ip
      user                = "ubuntu"
      private_key         = file(var.ssh_key_file_name)
      bastion_host        = aws_instance.proxy.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = file(var.ssh_key_file_name)
    }
  }

  tags = {
    Name        = "bhofmann-cluster-vm-${count.index}"
    Creator     = "bhofmann"
    Owner       = "bhofmann"
    DoNotDelete = "true"
  }
}
