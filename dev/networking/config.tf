terraform {
  backend "s3" {
    bucket = "dev-S3"      
    key    = "network/terraform.tfstate" 
    region = "us-east-1"
  }
}