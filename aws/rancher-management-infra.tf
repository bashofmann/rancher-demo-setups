# AWS infrastructure resources

# Temporary key pair used for SSH accesss
resource "aws_key_pair" "quickstart_key_pair" {
  key_name_prefix = "${var.prefix}-rancher-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}

// TODO more
# Security group to allow all traffic
resource "aws_security_group" "rancher_sg_allowall" {
  name        = "${var.prefix}-rancher-allowall"
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

  tags = {
    Creator = "rancher-quickstart"
  }
}

resource "aws_instance" "rancher_server" {
  count         = var.rancher_server_cluster_nodes
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name        = aws_key_pair.quickstart_key_pair.key_name
  security_groups = [aws_security_group.rancher_sg_allowall.name]

  user_data = templatefile("../userdata/server.sh", {
    docker_version = var.docker_version
    username       = local.node_username
  })

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

  tags = {
    Name    = "${var.prefix}-rancher-server"
    Creator = "rancher-quickstart"
  }
}

resource "aws_elb" "rancher-server-lb" {
  name               = "${var.prefix}-rancher-server-lb"
  availability_zones = aws_instance.rancher_server[*].availability_zone

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 6443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  instances                   = aws_instance.rancher_server[*].id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.prefix}-rancher-server-lb"
  }
}