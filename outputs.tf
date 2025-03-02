output "minecraft_server_url" {
  description = "Address to access the Minecraft server"
  value       = local.fqdn
}

output "minecraft_server_address" {
  description = "Minecraft server address to use in the game client"
  value       = local.fqdn
}

# ECR repository output has been removed

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.ecs.nlb_dns_name
}

output "efs_id" {
  description = "ID of the EFS file system"
  value       = module.storage.efs_id
}
