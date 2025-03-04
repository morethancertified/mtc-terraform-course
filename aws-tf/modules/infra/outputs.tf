output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "public_subnets" {
  value = [for i in aws_subnet.this : i.id]
}

# output "subnets" {
#   value = aws_subnet.this
# }

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "alb_listener_arn" {
  value = aws_lb_listener.this.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}