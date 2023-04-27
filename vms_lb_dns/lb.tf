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

resource "aws_elb" "opni-lb" {
  name            = "${var.prefix}-opni-lb"
  subnets         = [aws_subnet.eu-central-1a-public.id]
  security_groups = [aws_security_group.rancher.id]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:32090"
    interval            = 30
  }

  listener {
    instance_port     = 32090
    instance_protocol = "tcp"
    lb_port           = 9090
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 32000
    instance_protocol = "tcp"
    lb_port           = 4000
    lb_protocol       = "tcp"
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
    Name = "${var.prefix}-opni-lb"
  }
}

data "digitalocean_domain" "zone" {
  name = "plgrnd.be"
}

resource "digitalocean_record" "rancher" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "rancher"
  value  = "${aws_elb.rancher-server-lb.dns_name}."
  ttl    = 60
}

resource "digitalocean_record" "opni" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "opni"
  value  = "${aws_elb.opni-lb.dns_name}."
  ttl    = 60
}

resource "digitalocean_record" "grafana" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "grafana"
  value  = "${aws_elb.rancher-server-lb.dns_name}."
  ttl    = 60
}

resource "digitalocean_record" "logs" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "logs"
  value  = "${aws_elb.rancher-server-lb.dns_name}."
  ttl    = 60
}

resource "digitalocean_record" "keycloak" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "keycloak"
  value  = "${aws_elb.rancher-server-lb.dns_name}."
  ttl    = 60
}

resource "aws_elb" "kubernetes-lb" {
  name            = "${var.prefix}-kubernetes-lb"
  subnets         = [aws_subnet.eu-central-1a-public.id]
  security_groups = [aws_security_group.rancher.id]

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 6443
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 9345
    instance_protocol = "tcp"
    lb_port           = 9345
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:9345"
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
    Name = "${var.prefix}-reg-lb"
  }
}

resource "digitalocean_record" "kubernetes" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "kubernetes"
  value  = "${aws_elb.kubernetes-lb.dns_name}."
  ttl    = 60
}
