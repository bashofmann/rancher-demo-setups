resource "aws_security_group" "rancher_sg_allowall" {
  name        = "${var.prefix}-rancher-allowall"
  description = "Rancher - allow all traffic"

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

  tags = map(
    "kubernetes.io/cluster/${rancher2_cluster.demo.id}", "owned"
  )
}