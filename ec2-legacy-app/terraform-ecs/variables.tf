variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ec2-to-ecs-migration"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
}

variable "container_port" {
  description = "The port the application listens on inside and outside the container"
  type        = number
  default     = 5000
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ecs_cpu" {
  description = "CPU units allocated to the ECS Fargate task"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Memory in MiB allocated to the ECS Fargate task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks the service should run"
  type        = number
  default     = 1
}

variable "domain_name" {
  description = "Domain name for Route53 record"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}