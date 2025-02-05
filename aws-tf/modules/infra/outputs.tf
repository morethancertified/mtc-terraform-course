output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "public_subnets" {
  value = [for i in aws_subnet.this : i.id]
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}