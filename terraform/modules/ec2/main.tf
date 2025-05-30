resource "aws_instance" "processing_server" {
  ami                    = "ami-0cfa2ad4242c3168d"
  instance_type          = "t2.large"
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = templatefile("${path.module}/user_data.sh", {
    processed_bucket = var.processed_bucket
  })

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "ModelServer"
  }
}

output "ec2_public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.processing_server.public_ip
}

output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.processing_server.id
}
