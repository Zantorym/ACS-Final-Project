terraform {
  backend "s3" {
    bucket = "prod-s3-acsgroup13"
    key    = "prod-network/terraform.tfstate"
    region = "us-east-1"
  }
}
