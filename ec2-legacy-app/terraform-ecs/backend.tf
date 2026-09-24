terraform {
  backend "s3" {
    bucket       = "hassan-terraform-state-bucket"
    key          = "ec2-to-ecs-migration/production/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}