terraform {
  backend "s3" {
    bucket       = "hassan-terraform-state-bucket"
    key          = "ec2-to-ecs-migration/production/terraform.tfstate"
    region       = var.aws_region
    use_lockfile = true
  }
}