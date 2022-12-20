terraform {
  backend "s3" {
    bucket = "dev-s3-acsgroup13-jp"
    key    = "dev-network/terraform.tfstate"
    region = "us-east-1"
  }
}