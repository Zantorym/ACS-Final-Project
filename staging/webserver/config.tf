terraform {
  backend "s3" {
    bucket = "staging-S3"      
    key    = "webserver/terraform.tfstate" 
    region = "us-east-1"
  }
}