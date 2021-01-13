resource "aws_security_group" "instance_default_sg" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.instance_ssh_cidr_blocks
  }

  tags = merge(local.tags, {Role = "instance"})
  vpc_id = var.vpc_id
}
