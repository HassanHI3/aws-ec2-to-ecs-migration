# Application Load balancer

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false # Public / Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id] # 2 subnets in different AZs = multi AZ coverage

  enable_deletion_protection = false # Set to true for production systems

  tags = {
    Environment = var.environment
  }
}

# 3. ALB TARGET GROUP (Where ECS tasks register)

resource "aws_lb_target_group" "ecs_target_group" {
  name        = "${var.project_name}-${var.environment}-ecs-tg"
  port        = var.container_port # port inside my container which is 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # Crucial: Must be set to 'ip' for AWS Fargate compatibility

  health_check {
    enabled             = true
    path                = "/health" # e.g., "/" or "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  tags = {
    Environment = var.environment
  }
}


# 4. ALB LISTENER

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: Forward incoming traffic directly to our ECS target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}


# listens on port 80 and forwards to my ecs tasks which are on port 5000
# internet traffic on port 80 -> ALB listens on port 80 -> forwards to ecs tasks on port 5000 that are in my private subnet