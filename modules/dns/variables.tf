variable "domain_name" {
  description = "Domain name for the Minecraft server"
  type        = string
}

variable "minecraft_subdomain" {
  description = "Subdomain for the Minecraft server"
  type        = string
  default     = "mc"
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
