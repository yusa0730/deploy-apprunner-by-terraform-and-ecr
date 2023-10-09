provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
  }
  backend "s3" {
    bucket = "leadhack-lesson-bucket"
    key    = "dev/20231008/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

