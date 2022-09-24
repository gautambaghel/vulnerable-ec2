output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.ec2.public_ip
}