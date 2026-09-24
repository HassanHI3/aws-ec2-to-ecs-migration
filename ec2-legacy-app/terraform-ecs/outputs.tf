output "application_url" {
  description = "Public URL for accessing the application through the ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.ec2_legacy_app.repository_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# "What will I need after Terraform has finished?"

# Can I access the app?       → application_url
# Where is my image repo?     → ecr_repository_url
# What cluster was created?   → ecs_cluster_name
# What service is running?    → ecs_service_name
# What network is it using?   → vpc_id
