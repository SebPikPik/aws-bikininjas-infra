output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.minecraft.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.minecraft.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.minecraft.arn
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.minecraft.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.minecraft.zone_id
}
