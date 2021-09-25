output "instance_ami" {
  value = aws_instance.linux.*.ami
}

output "instance_arn" {
  value = aws_instance.linux.*.arn
}
