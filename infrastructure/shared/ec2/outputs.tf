output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "public_ip" {
  description = "Public IP of the EC2 instance (if EIP is created)"
  value       = var.create_eip ? aws_eip.main[0].public_ip : null
}

