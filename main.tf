terraform {
  required_version = "~> 1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  
  backend "s3" {
    bucket = "s3aws-tfstate"
    key    = "minecraft/terraform.tfstate"
    region = "eu-west-3"
    # Uncomment and set these values if you need DynamoDB locking
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for the current AWS account ID
data "aws_caller_identity" "current" {}

# Local variables
locals {
  name_prefix         = "minecraft"
  environment         = var.environment
  domain_name         = "bikininja.click"
  minecraft_subdomain = "mc"
  fqdn                = "${local.minecraft_subdomain}.${local.domain_name}"
  container_port      = 25565
  tags = {
    Project     = "Minecraft Server"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Networking module - VPC, subnets, security groups, etc.
module "networking" {
  source = "./modules/networking"
  
  name_prefix         = local.name_prefix
  environment         = local.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  container_port      = local.container_port
  tags                = local.tags
}

# ECR module has been removed

# Storage module - EFS for persistent Minecraft data
module "storage" {
  source = "./modules/storage"
  
  name_prefix     = local.name_prefix
  environment     = local.environment
  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.private_subnet_ids
  security_groups = [module.networking.efs_security_group_id]
  tags            = local.tags
}

# DNS module - Route53 and ACM for domain and SSL certificate
module "dns" {
  source = "./modules/dns"
  
  domain_name         = local.domain_name
  minecraft_subdomain = local.minecraft_subdomain
  nlb_dns_name        = module.ecs.nlb_dns_name
  nlb_zone_id         = module.ecs.nlb_zone_id
  tags                = local.tags
}

# ECS module - Fargate service for running the Minecraft server
module "ecs" {
  source = "./modules/ecs"
  
  name_prefix         = local.name_prefix
  environment         = local.environment
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  private_subnet_ids  = module.networking.private_subnet_ids
  security_groups     = [module.networking.ecs_security_group_id]
  efs_id              = module.storage.efs_id
  efs_access_point_id = module.storage.efs_access_point_id
  container_port      = local.container_port
  minecraft_version   = var.minecraft_version
  minecraft_eula      = var.minecraft_eula
  certificate_arn     = module.dns.certificate_arn
  tags                = local.tags
}
