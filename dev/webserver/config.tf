terraform {
  backend "s3" {
    bucket = "dev-S3"      
    key    = "webserver/terraform.tfstate" 
    region = "us-east-1"
  }
}