terraform {
  backend "s3" {
    bucket = "staging-s3-2"      
    key    = "webserver/terraform.tfstate" 
    region = "us-east-1"
  }
}