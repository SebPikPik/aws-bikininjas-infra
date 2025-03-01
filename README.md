# AWS Minecraft Server Infrastructure

This repository contains Terraform code to deploy a Minecraft server on AWS using ECS (Elastic Container Service) with Fargate. The infrastructure is designed to be scalable, secure, and maintainable, with persistent storage for the Minecraft world data.

## Features

- **Containerized Minecraft Server**: Runs the latest Paper Minecraft server in a Docker container on AWS ECS Fargate
- **Custom Domain**: Uses Route53 for the domain `bikininja.click` for easier access to the Minecraft server
- **Persistent Storage**: EFS (Elastic File System) for storing Minecraft world data
- **Private Container Registry**: ECR (Elastic Container Registry) for storing the Minecraft server Docker image
- **Load Balancing**: Network Load Balancer for handling Minecraft TCP traffic
- **Security**: Proper security groups and IAM roles with least privilege
- **Modular Design**: Terraform code organized in modules for better maintainability

## Architecture

The infrastructure is deployed in the `eu-west-3` (Paris) region and consists of:

- VPC with public and private subnets across multiple availability zones
- ECS Fargate for running the Minecraft server container
- ECR for storing the Docker image
- EFS for persistent storage of Minecraft world data
- Route53 for DNS management
- Network Load Balancer for TCP traffic management

## Repository Structure

```
.
├── main.tf              # Main Terraform configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── Dockerfile           # Dockerfile for the Minecraft server
├── entrypoint.sh        # Entrypoint script for the Docker container
└── modules/             # Terraform modules
    ├── networking/      # VPC, subnets, security groups
    ├── ecr/             # Container registry
    ├── ecs/             # ECS cluster, service, task definition
    ├── storage/         # EFS for persistent storage
    └── dns/             # Route53 and ACM for domain and certificate
```

## Prerequisites

1. AWS account with appropriate permissions
2. Terraform installed (version >= 1.10.5)
3. AWS CLI configured
4. Docker installed (for building and pushing the container image)
5. Domain `bikininja.click` registered and managed in Route53

## Deployment Instructions

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Build and Push the Docker Image

```bash
# Get the ECR repository URL from Terraform output after initial apply
aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url)

# Build the Docker image
docker build -t minecraft-server .

# Tag the image
docker tag minecraft-server:latest $(terraform output -raw ecr_repository_url):latest

# Push the image to ECR
docker push $(terraform output -raw ecr_repository_url):latest
```

### 3. Apply Terraform Configuration

```bash
terraform apply
```

### 4. Connect to the Minecraft Server

After deployment, you can connect to the Minecraft server using the domain:

```
mc.bikininja.click:25565
```

## Customization

You can customize the deployment by modifying the variables in `variables.tf`. Key variables include:

- `minecraft_version`: The version of Paper Minecraft to use
- `environment`: The environment name (e.g., prod, dev)
- `vpc_cidr`: The CIDR block for the VPC
- `availability_zones`: The availability zones to use

## Maintenance

### Updating the Minecraft Server

To update the Minecraft server to a new version:

1. Update the `minecraft_version` variable in `variables.tf`
2. Rebuild and push the Docker image
3. Apply the Terraform configuration

### Backup and Restore

The Minecraft world data is stored on EFS, which is automatically backed up. You can also create manual backups by:

1. Creating an EFS snapshot
2. Using AWS Backup to create scheduled backups

## Troubleshooting

- **Container Fails to Start**: Check the CloudWatch logs for the ECS task
- **Cannot Connect to Server**: Verify security groups and network ACLs
- **DNS Issues**: Ensure the Route53 records are correctly configured

## License

See the [LICENSE](LICENSE) file for details.