terraform {
  backend "s3" {
    bucket = "dev-s3-acsgroup13"
    key    = "dev-webserver/terraform.tfstate"
    region = "us-east-1"
  }
}