output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.minecraft.id
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.minecraft.dns_name
}

output "efs_access_point_id" {
  description = "ID of the EFS access point"
  value       = aws_efs_access_point.minecraft.id
}
