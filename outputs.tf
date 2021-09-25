output "instance_ami" {
  value = aws_instance.linux.*.ami
}

output "instance_arn" {
  value = aws_instance.linux.*.arn
}

output "dns" {
  value = aws_instance.linux.*.public_dns
}
