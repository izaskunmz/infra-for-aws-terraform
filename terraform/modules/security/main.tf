# Security Group para la EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Reglas de seguridad para la EC2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-SecurityGroup"
  }
}

# ✅ Agrega este Output al final
output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}