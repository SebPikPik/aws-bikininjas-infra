variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ECS tasks"
  type        = list(string)
}

variable "efs_id" {
  description = "ID of the EFS file system"
  type        = string
}

variable "efs_access_point_id" {
  description = "ID of the EFS access point"
  type        = string
}

# ECR repository URL variable has been removed

variable "container_port" {
  description = "Port on which the container will receive traffic"
  type        = number
  default     = 25565
}

variable "minecraft_version" {
  description = "Minecraft Paper version to use"
  type        = string
  default     = "latest"
}

variable "minecraft_eula" {
  description = "Accept Minecraft EULA"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate (not used for TCP traffic)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
