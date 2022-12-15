terraform {
  backend "s3" {
    bucket = "staging-s3"      
    key    = "network/terraform.tfstate" 
    region = "us-east-1"
  }
}