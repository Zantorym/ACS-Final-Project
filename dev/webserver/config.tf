terraform {
  backend "s3" {
    bucket = "dev-s3-acsgroup13"
    key    = "webserver/terraform.tfstate"
    region = "us-east-1"
  }
}