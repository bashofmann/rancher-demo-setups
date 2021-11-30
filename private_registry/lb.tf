resource "aws_elb" "rancher-server-lb" {
  name            = "${var.prefix}-rancher-server-lb"
  subnets         = [aws_subnet.eu-central-1a-public.id]
  security_groups = [aws_security_group.rancher.id]

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

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  instances = [
    aws_instance.vmlb[0].id,
    aws_instance.vmlb[1].id,
    aws_instance.vmlb[2].id
  ]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.prefix}-vmlb-lb"
  }
}

//resource "aws_proxy_protocol_policy" "smtp" {
//  load_balancer  = aws_elb.rancher-server-lb.name
//  instance_ports = ["80", "443"]
//}

data "digitalocean_domain" "zone" {
  name = "plgrnd.be"
}

resource "digitalocean_record" "wildcard" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "rancher"
  value  = "${aws_elb.rancher-server-lb.dns_name}."
  ttl    = 60
}

resource "aws_elb" "registry-server-lb" {
  name            = "${var.prefix}-registry-server-lb"
  subnets         = [aws_subnet.eu-central-1a-public.id]
  security_groups = [aws_security_group.rancher.id]

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

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  instances = [
    aws_instance.vmlb[3].id,
  ]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.prefix}-reg-lb"
  }
}

resource "digitalocean_record" "registry" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "registry"
  value  = "${aws_elb.registry-server-lb.dns_name}."
  ttl    = 60
}