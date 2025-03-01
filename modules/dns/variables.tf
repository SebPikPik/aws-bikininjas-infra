variable "domain_name" {
  description = "Domain name for the Minecraft server"
  type        = string
}

variable "minecraft_subdomain" {
  description = "Subdomain for the Minecraft server"
  type        = string
  default     = "mc"
}

variable "nlb_dns_name" {
  description = "DNS name of the NLB"
  type        = string
}

variable "nlb_zone_id" {
  description = "Zone ID of the NLB"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
