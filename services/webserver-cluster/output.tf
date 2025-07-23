output "alb_dns_name" {
  description = "The public ip of the instance"
  value       = aws_lb.lb-example.dns_name
}

# output "db-address" {
#   description = "db-output from data"
#   value       = data.terraform_remote_state.mysql-db.outputs.db_address
# }

# output "db-port" {
#   description = "db-output from ports"
#   value       = data.terraform_remote_state.mysql-db.outputs.db_port
# }

output "asg-name" {
  description = "auto-scaling group name"
  value = aws_autoscaling_group.web-server-SG.name

}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
  description = "The ID of the Security Group attached to the load balancer"
}

output "instance_security_group_id" {
  value = aws_security_group.sg-terra-test-1.id
  description = "The ID of the Security Group attached to the load balancer"
}
