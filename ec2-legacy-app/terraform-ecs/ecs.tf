

# 1. ECS CLUSTER & TASK DEFINITION

# Core ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
  tags = {
    Environment = var.environment
  }
}

# Task Definition detailing the container specifications

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn



  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = var.container_image
      essential = true

      # Injects the dynamic port variable into the application environment
      environment = [
        {
          name  = "PORT"
          value = tostring(var.container_port)
        }
      ]

      # Maps the dynamic port on the container boundary
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      # Sends container logs to CloudWatch
      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "${var.project_name}-ecs"
        }
      }
    }
  ])
}


# 2. ECS SERVICE RUNNING ON FARGATE

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id] # Running Fargate tasks in private subnets for security
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false # Set to false deploying to private subnets for fargate tasks
  }

  # how does the ALB find the ecs service ?
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "${var.project_name}-container"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.http
  ]
}
#ALB → ECS     = inbound application traffic ✅
#ECS → ECR     = outbound image-pull traffic ✅
