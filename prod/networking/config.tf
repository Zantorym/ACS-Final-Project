terraform {
  backend "s3" {
    bucket = "s3-final-prod"
    key    = "prod-networking/terraform.tfstate"
    region = "us-east-1"
  }
}