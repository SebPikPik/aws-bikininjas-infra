#!/bin/bash

# Script to clean up AWS resources with dependency issues
# This script handles resources in the correct order to avoid dependency violations

set -e

# Set AWS region
export AWS_REGION=${AWS_REGION:-eu-west-3}
echo "Using AWS region: $AWS_REGION"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required tools
if ! command_exists aws; then
  echo "Error: AWS CLI is not installed. Please install it first."
  exit 1
fi

if ! command_exists jq; then
  echo "Error: jq is not installed. Please install it first."
  exit 1
fi

echo "⛏️ Starting Minecraft infrastructure cleanup..."

# 1. Stop any running ECS tasks
echo "🔍 Checking for running ECS tasks..."
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name 2>/dev/null || echo "minecraft-cluster")
RUNNING_TASKS=$(aws ecs list-tasks --cluster $CLUSTER_NAME --query 'taskArns' --output text 2>/dev/null || echo "")

if [ -n "$RUNNING_TASKS" ]; then
  echo "🛑 Stopping ECS tasks..."
  for task in $RUNNING_TASKS; do
    aws ecs stop-task --cluster $CLUSTER_NAME --task $task
    echo "  - Stopped task: $task"
  done
  echo "⏳ Waiting 60 seconds for tasks to fully stop..."
  sleep 60
else
  echo "  - No running tasks found."
fi

# 2. Delete EFS mount targets
echo "🔍 Checking for EFS mount targets..."
EFS_ID=$(terraform output -raw efs_id 2>/dev/null || aws efs describe-file-systems --query "FileSystems[?contains(Name, 'minecraft')].FileSystemId" --output text)

if [ -n "$EFS_ID" ]; then
  echo "  - Found EFS: $EFS_ID"
  MOUNT_TARGETS=$(aws efs describe-mount-targets --file-system-id $EFS_ID --query "MountTargets[*].MountTargetId" --output text 2>/dev/null || echo "")
  
  if [ -n "$MOUNT_TARGETS" ]; then
    echo "🗑️ Deleting EFS mount targets..."
    for mt in $MOUNT_TARGETS; do
      aws efs delete-mount-target --mount-target-id $mt
      echo "  - Deleted mount target: $mt"
    done
    echo "⏳ Waiting 60 seconds for mount targets to be fully deleted..."
    sleep 60
  else
    echo "  - No mount targets found."
  fi
else
  echo "  - No EFS file system found."
fi

# 3. Release Elastic IPs
echo "🔍 Checking for Elastic IPs..."
EIPS=$(aws ec2 describe-addresses --query "Addresses[*].AllocationId" --output text)

if [ -n "$EIPS" ]; then
  echo "🗑️ Releasing Elastic IPs..."
  for eip in $EIPS; do
    # Check if the EIP is associated with an instance or network interface
    ASSOCIATION_ID=$(aws ec2 describe-addresses --allocation-ids $eip --query "Addresses[0].AssociationId" --output text)
    
    if [ "$ASSOCIATION_ID" != "None" ] && [ -n "$ASSOCIATION_ID" ]; then
      echo "  - Disassociating EIP: $eip (Association: $ASSOCIATION_ID)"
      aws ec2 disassociate-address --association-id $ASSOCIATION_ID || echo "  - Failed to disassociate, may already be disassociated"
      sleep 5
    fi
    
    echo "  - Releasing EIP: $eip"
    aws ec2 release-address --allocation-id $eip || echo "  - Failed to release EIP, may be in use or already released"
  done
else
  echo "  - No Elastic IPs found."
fi

# 4. Find and delete any NAT Gateways
echo "🔍 Checking for NAT Gateways..."
NAT_GATEWAYS=$(aws ec2 describe-nat-gateways --filter "Name=state,Values=available,pending" --query "NatGateways[*].NatGatewayId" --output text)

if [ -n "$NAT_GATEWAYS" ]; then
  echo "🗑️ Deleting NAT Gateways..."
  for nat in $NAT_GATEWAYS; do
    aws ec2 delete-nat-gateway --nat-gateway-id $nat
    echo "  - Deleted NAT Gateway: $nat"
  done
  echo "⏳ Waiting 90 seconds for NAT Gateways to be deleted..."
  sleep 90
else
  echo "  - No NAT Gateways found."
fi

# 5. Find and delete Load Balancers
echo "🔍 Checking for Load Balancers..."
LOAD_BALANCERS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[*].LoadBalancerArn" --output text 2>/dev/null || echo "")

if [ -n "$LOAD_BALANCERS" ]; then
  echo "🗑️ Deleting Load Balancers..."
  for lb in $LOAD_BALANCERS; do
    aws elbv2 delete-load-balancer --load-balancer-arn $lb
    echo "  - Deleted Load Balancer: $lb"
  done
  echo "⏳ Waiting 60 seconds for Load Balancers to be deleted..."
  sleep 60
else
  echo "  - No Load Balancers found."
fi

# 6. Find and delete Target Groups
echo "🔍 Checking for Target Groups..."
TARGET_GROUPS=$(aws elbv2 describe-target-groups --query "TargetGroups[*].TargetGroupArn" --output text 2>/dev/null || echo "")

if [ -n "$TARGET_GROUPS" ]; then
  echo "🗑️ Deleting Target Groups..."
  for tg in $TARGET_GROUPS; do
    aws elbv2 delete-target-group --target-group-arn $tg
    echo "  - Deleted Target Group: $tg"
  done
else
  echo "  - No Target Groups found."
fi

# 7. Now try running terraform destroy
echo "⚡ Running terraform destroy..."
terraform destroy -auto-approve

echo "✅ Cleanup process completed!"
