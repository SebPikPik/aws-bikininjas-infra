# ECS Cluster
resource "aws_ecs_cluster" "minecraft" {
  name = "${var.name_prefix}-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_execution" {
  name = "${var.name_prefix}-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policies to the ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name = "${var.name_prefix}-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Policy for ECS Task Role to access EFS
resource "aws_iam_policy" "ecs_efs_access" {
  name        = "${var.name_prefix}-efs-access-${var.environment}"
  description = "Allow ECS tasks to access EFS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = "arn:aws:elasticfilesystem:*:*:file-system/${var.efs_id}"
      }
    ]
  })
}

# Attach EFS access policy to the ECS Task Role
resource "aws_iam_role_policy_attachment" "ecs_efs_access" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_efs_access.arn
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "minecraft" {
  name              = "/ecs/${var.name_prefix}-${var.environment}"
  retention_in_days = 30

  tags = var.tags
}

# Task Definition
resource "aws_ecs_task_definition" "minecraft" {
  family                   = "${var.name_prefix}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "minecraft"
      image     = "${var.ecr_repository_url}:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "EULA"
          value = tostring(var.minecraft_eula)
        },
        {
          name  = "VERSION"
          value = var.minecraft_version
        },
        {
          name  = "TYPE"
          value = "PAPER"
        },
        {
          name  = "MEMORY"
          value = "1G"
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "minecraft-data"
          containerPath = "/data"
          readOnly      = false
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.minecraft.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  volume {
    name = "minecraft-data"
    
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  tags = var.tags
}

# Network Load Balancer for Minecraft TCP traffic
resource "aws_lb" "minecraft" {
  name               = "${var.name_prefix}-nlb-${var.environment}"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = var.tags
}

# Target Group for Minecraft TCP traffic
resource "aws_lb_target_group" "minecraft" {
  name        = "${var.name_prefix}-tg-${var.environment}"
  port        = var.container_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = var.tags
}

# Minecraft TCP Listener
resource "aws_lb_listener" "minecraft" {
  load_balancer_arn = aws_lb.minecraft.arn
  port              = var.container_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minecraft.arn
  }
}

# ECS Service
resource "aws_ecs_service" "minecraft" {
  name            = "${var.name_prefix}-service-${var.environment}"
  cluster         = aws_ecs_cluster.minecraft.id
  task_definition = aws_ecs_task_definition.minecraft.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.minecraft.arn
    container_name   = "minecraft"
    container_port   = var.container_port
  }

  # Ignore changes to desired_count to allow manual scaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_lb_listener.minecraft
  ]

  tags = var.tags
}
