terraform {
  backend "s3" {
    bucket = "prod-S3"      
    key    = "network/terraform.tfstate" 
    region = "us-east-1"
  }
}