output "ecs_cluster_id" {
  value       = aws_ecs_cluster.cluster.id
  description = "id of the cluster"
}

output "ecs_cluster_name" {
  value       = local.name
  description = "name of the cluster"
}

output "ecs_cluster_sg" {
  value       = aws_security_group.instance_default_sg.id
  description = "security group of the cluster"
}
