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

# Use existing IAM role
data "aws_iam_role" "existing_role" {
  name = "WordpressRole"
}

# Create only the instance profile with a unique name
resource "aws_iam_instance_profile" "wordpress_profile" {
  name = "wordpress-profile-new"
  role = data.aws_iam_role.existing_role.name
}