terraform {
  backend "s3" {
    bucket = "staging-S3"      
    key    = "network/terraform.tfstate" 
    region = "us-east-1"
  }
}