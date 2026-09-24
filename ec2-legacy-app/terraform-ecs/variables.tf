variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
variable "container_image" {
  description = "Docker image for the application"
  type        = string
}

variable "container_port" {
  description = "The port the application listens on inside and outside the container"
  type        = number
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "ecs_cpu" {
  description = "CPU units allocated to the ECS Fargate task"
  type        = number
}

variable "ecs_memory" {
  description = "Memory in MiB allocated to the ECS Fargate task"
  type        = number
}

variable "desired_count" {
  description = "Number of ECS tasks the service should run"
  type        = number
}