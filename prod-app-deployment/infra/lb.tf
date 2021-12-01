resource "aws_elb" "k8sdemo-lb" {
  name            = "k8sdemo-lb"
  subnets         = [aws_subnet.k8sdemo-subnet.id]
  security_groups = [aws_security_group.k8sdemo-sg.id]

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
    aws_instance.k8sdemo-vm[0].id,
    aws_instance.k8sdemo-vm[1].id,
    aws_instance.k8sdemo-vm[2].id,
    aws_instance.k8sdemo-vm[3].id,
    aws_instance.k8sdemo-vm[4].id,
  ]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "k8sdemo-vmlb-lb"
  }
}

data "digitalocean_domain" "zone" {
  name = "plgrnd.be"
}

resource "digitalocean_record" "rancher" {
  domain = data.digitalocean_domain.zone.name
  type   = "CNAME"
  name   = "*.k8sdemo"
  value  = "${aws_elb.k8sdemo-lb.dns_name}."
  ttl    = 60
}