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

# Use hardcoded availability zones
locals {
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Security group for WordPress
resource "aws_security_group" "SGWordpress" {
  name        = "SGWordpress"
  description = "Control access to Wordpress Instance(s)"

  ingress {
    description = "Allow HTTP IPv4 IN"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGWordpress"
  }
}

# Use existing IAM role
data "aws_iam_role" "existing_wordpress_role" {
  name = "WordpressRole"
}

resource "aws_iam_instance_profile" "WordpressInstanceProfile" {
  name = "WordpressInstanceProfile"
  path = "/"
  role = data.aws_iam_role.existing_wordpress_role.name
}