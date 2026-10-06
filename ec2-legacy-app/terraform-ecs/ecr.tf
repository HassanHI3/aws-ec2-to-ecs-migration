# ECR repo is managed outside this stack so destroy/rebuild keeps the images.
removed {
  from = aws_ecr_repository.ec2_legacy_app
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_ecr_lifecycle_policy.legacy_app
  lifecycle {
    destroy = false
  }
}

data "aws_ecr_repository" "ec2_legacy_app" {
  name = "ec2-legacy-app"
}