resource "aws_key_pair" "quickstart_key_pair" {
  key_name_prefix = "${var.prefix}-k3s-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}


resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "bhofmann-test-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "bhofmann Public Subnet"
  }
}

resource "aws_route_table" "eu-central-1a-public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "bhofmann Public Subnet"
  }
}

resource "aws_route_table_association" "eu-central-1a-public" {
  subnet_id      = aws_subnet.eu-central-1a-public.id
  route_table_id = aws_route_table.eu-central-1a-public.id
}

resource "aws_security_group" "rancher_sg_allowall" {
  name        = "${var.prefix}-k3s-allowall"
  description = "Rancher quickstart - allow all traffic"
  vpc_id = aws_vpc.default.id

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

resource "aws_instance" "k3s" {
  count         = var.vm_count
  ami           = data.aws_ami.sles.id
  instance_type = var.instance_type

  key_name        = aws_key_pair.quickstart_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.rancher_sg_allowall.id]
  subnet_id                   = aws_subnet.eu-central-1a-public.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 80
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file(var.ssh_key_file_name)
    }
  }

  tags = {
    Name        = "${var.prefix}-k3s-${count.index}"
    Owner       = "bhofmann"
    DoNotDelete = "true"
  }
}
