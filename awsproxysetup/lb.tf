resource "aws_eip" "rancher" {
  vpc = true
}
resource "aws_lb" "rancher-lb" {
  name               = "bhofmann-rancher-nlb"
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id     = aws_subnet.eu-central-1a-public.id
    allocation_id = aws_eip.rancher.id
  }
}
resource "aws_lb_listener" "rancher-lb-listener_80" {
  load_balancer_arn = aws_lb.rancher-lb.id
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.bhofmann-lb-target-80.id
    type             = "forward"
  }
}
resource "aws_lb_target_group" "bhofmann-lb-target-80" {
  name = "bhofmann-lb-target-80"
  port = 80

  protocol    = "TCP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"

  depends_on = [aws_lb.rancher-lb]
}
resource "aws_lb_listener" "rancher-lb-listener-443" {
  load_balancer_arn = aws_lb.rancher-lb.id
  port              = 443
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.bhofmann-lb-target-443.id
    type             = "forward"
  }
}
resource "aws_lb_target_group" "bhofmann-lb-target-443" {
  name = "bhofmann-lb-target-443"
  port = 443

  protocol    = "TCP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"

  depends_on = [aws_lb.rancher-lb]
}
resource "aws_lb_target_group_attachment" "rancher-target-group-80" {
  for_each         = toset(aws_instance.private_vms[*].private_ip)
  target_group_arn = aws_lb_target_group.bhofmann-lb-target-80.arn
  target_id        = each.key
  port             = 80
}
resource "aws_lb_target_group_attachment" "rancher-target-group_443" {
  for_each         = toset(aws_instance.private_vms[*].private_ip)
  target_group_arn = aws_lb_target_group.bhofmann-lb-target-443.arn
  target_id        = each.key
  port             = 443
}

data "digitalocean_domain" "rancher" {
  name = var.rancher_domain
}

resource "digitalocean_record" "rancher" {
  domain = data.digitalocean_domain.rancher.name
  type   = "A"
  name   = var.rancher_subdomain
  value  = aws_eip.rancher.public_ip
  ttl    = 60
}
