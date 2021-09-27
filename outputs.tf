output "instance_ami" {
  value = aws_instance.linux.*.ami
}

output "instance_arn" {
  value = aws_instance.linux.*.arn
}

output "server_dns" {
  value = aws_instance.linux.*.public_dns
}

output "elb_dns" {
  value = aws_elb.lb_web_server.dns_name
}
