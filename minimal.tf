terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use existing security group instead of creating one
data "aws_security_group" "existing_sg" {
  name = "default"
}

# Use existing IAM role
data "aws_iam_role" "existing_role" {
  name = "WordpressRole"
}

# Use existing instance profile or create if it doesn't exist
resource "aws_iam_instance_profile" "profile" {
  name = "WordpressProfile"
  role = data.aws_iam_role.existing_role.name
}