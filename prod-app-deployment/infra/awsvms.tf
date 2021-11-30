resource "aws_key_pair" "quickstart_key_pair" {
  key_name_prefix = "k8sdemo-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}

resource "aws_vpc" "k8sdemo-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "k8sdemo-vpc"
  }
}

resource "aws_internet_gateway" "k8sdemo-gateway" {
  vpc_id = aws_vpc.k8sdemo-vpc.id
}

resource "aws_subnet" "k8sdemo-subnet" {
  vpc_id = aws_vpc.k8sdemo-vpc.id

  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "k8sdemo-subnet"
  }
}

resource "aws_route_table" "k8sdemo-rt" {
  vpc_id = aws_vpc.k8sdemo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8sdemo-gateway.id
  }

  tags = {
    Name = "k8sdemo-rt"
  }
}

resource "aws_route_table_association" "eu-central-1a-public" {
  subnet_id      = aws_subnet.k8sdemo-subnet.id
  route_table_id = aws_route_table.k8sdemo-rt.id
}

resource "aws_security_group" "k8sdemo-sg" {
  name   = "k8sdemo"
  vpc_id = aws_vpc.k8sdemo-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30001
    to_port     = 30001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9345
    to_port     = 9345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [aws_vpc.k8sdemo-vpc.cidr_block]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8sdemo-vm" {
  count         = 5
  ami           = data.aws_ami.sles.id
  instance_type = var.instance_type

  key_name                    = aws_key_pair.quickstart_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8sdemo-sg.id]
  subnet_id                   = aws_subnet.k8sdemo-subnet.id
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "echo hello"
    ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file(var.ssh_key_file_name)
    }
  }

  root_block_device {
    volume_size = 80
  }

  tags = {
    Name = "k8sdemo-${count.index}"
  }
}
