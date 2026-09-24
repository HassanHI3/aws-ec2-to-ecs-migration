data "aws_iam_role" "ecs_execution_role" { # Task execution Role previously created so referencing with a data block in ECS.tf later
  name = "ecsTaskExecutionRole"
}




# resource "aws_iam_policy" "policy" {
#   name        = "test_policy"
#   path        = "/"
#   description = "My ECS Task Execution Role Policy"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         Effect   = "Allow"
#         "Action": [
#           "ecr:GetAuthorizationToken",
#                 "ecr:BatchCheckLayerAvailability",
#                 "ecr:GetDownloadUrlForLayer",
#                 "ecr:BatchGetImage",
#                 "logs:CreateLogStream",
#                 "logs:PutLogEvents"
#         ]

#         Resource = "*"
#       },
#     ]
#   })
# }
