terraform {
  backend "s3" {
    bucket = "s3-final-prod"
    key    = "prod-webserver/terraform.tfstate"
    region = "us-east-1"
  }
}