# Random string for the ECR repository name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# ECR Repository for Minecraft server image
resource "aws_ecr_repository" "minecraft" {
  name                 = "${var.name_prefix}-server-${random_string.suffix.result}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "minecraft" {
  repository = aws_ecr_repository.minecraft.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
