# 1. Define the Security Group for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Controls traffic flow to and from the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Ingress Rule: Allow HTTP traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Ingress Rule: Allow HTTPS traffic from anywhere (Optional - uncomment if using SSL)
# resource "aws_vpc_security_group_ingress_rule" "allow_https" {
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# Egress Rule: Allow all outbound traffic (Necessary to forward requests to backend instances)
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # -1 means all protocols
}


# 2. Define the Security Group for the ecs

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-tasks-security-group"
  description = "Allows incoming traffic strictly from the ALB and manages outbound access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}

# Ingress Rule: Allow traffic ONLY from the ALB's Security Group
resource "aws_vpc_security_group_ingress_rule" "allow_alb_traffic" {
  security_group_id            = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id # Ties ECS directly to your ALB SG
  from_port                    = 5000
  to_port                      = 5000
  ip_protocol                  = "tcp"
}

# Egress Rule: Allow all outbound traffic
# Required for ECS to pull images from ECR, connect to Secrets Manager, or fetch updates
resource "aws_vpc_security_group_egress_rule" "ecs_allow_all_outbound" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # -1 means all protocols
}
