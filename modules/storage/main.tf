# EFS File System for Minecraft data
resource "aws_efs_file_system" "minecraft" {
  creation_token = "${var.name_prefix}-efs-${var.environment}"
  encrypted      = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-efs-${var.environment}"
    }
  )
}

# EFS Mount Targets in each private subnet
resource "aws_efs_mount_target" "minecraft" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.minecraft.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_groups
}

# EFS Access Point for Minecraft data
resource "aws_efs_access_point" "minecraft" {
  file_system_id = aws_efs_file_system.minecraft.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/minecraft"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-efs-ap-${var.environment}"
    }
  )
}
