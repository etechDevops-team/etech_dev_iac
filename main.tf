terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Adjust as needed
}

resource "aws_vpc" "VPC" {
  cidr_block           = "10.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "A4LVPC"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "A4L-IGW"
  }
}

resource "aws_route_table" "RTPub" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "A4L-vpc-rt-pub"
  }
}

resource "aws_route" "RTPubDefaultIPv4" {
  route_table_id         = aws_route_table.RTPub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.InternetGateway.id
}

resource "aws_subnet" "SNPUBA" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.16.48.0/20"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-pub-A"
  }
}

resource "aws_subnet" "SNPUBB" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.16.112.0/20"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-pub-B"
  }
}

resource "aws_subnet" "SNPUBC" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.16.176.0/20"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-pub-C"
  }
}

resource "aws_subnet" "SNDBA" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.16.16.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "sn-db-A"
  }
}

resource "aws_subnet" "SNDBB" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.16.80.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "sn-db-B"
  }
}

resource "aws_subnet" "SNDBC" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.16.144.0/20"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "sn-db-C"
  }
}

resource "aws_subnet" "SNAPPA" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.16.32.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "sn-app-A"
  }
}

resource "aws_subnet" "SNAPPB" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.16.96.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "sn-app-B"
  }
}

resource "aws_subnet" "SNAPPC" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.16.160.0/20"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "sn-app-C"
  }
}

resource "aws_route_table_association" "RTAssociationPubA" {
  subnet_id      = aws_subnet.SNPUBA.id
  route_table_id = aws_route_table.RTPub.id
}

resource "aws_route_table_association" "RTAssociationPubB" {
  subnet_id      = aws_subnet.SNPUBB.id
  route_table_id = aws_route_table.RTPub.id
}

resource "aws_route_table_association" "RTAssociationPubC" {
  subnet_id      = aws_subnet.SNPUBC.id
  route_table_id = aws_route_table.RTPub.id
}

resource "aws_security_group" "SGWordpress" {
  name        = "SGWordpress"
  vpc_id      = aws_vpc.VPC.id
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

resource "aws_security_group" "SGDatabase" {
  name        = "SGDatabase"
  vpc_id      = aws_vpc.VPC.id
  description = "Control access to Database"

  ingress {
    description     = "Allow MySQL IN"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.SGWordpress.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGDatabase"
  }
}

resource "aws_security_group" "SGLoadBalancer" {
  name        = "SGLoadBalancer"
  vpc_id      = aws_vpc.VPC.id
  description = "Control access to Load Balancer"

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
    Name = "SGLoadBalancer"
  }
}

resource "aws_security_group" "SGEFS" {
  name        = "SGEFS"
  vpc_id      = aws_vpc.VPC.id
  description = "Control access to EFS"

  ingress {
    description     = "Allow NFS/EFS IPv4 IN"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.SGWordpress.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGEFS"
  }
}

resource "aws_iam_role" "WordpressRole" {
  name = "WordpressRole"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
  ]
}

resource "aws_iam_instance_profile" "WordpressInstanceProfile" {
  name = "WordpressInstanceProfile"
  path = "/"
  role = aws_iam_role.WordpressRole.name
}

resource "aws_ssm_parameter" "CWAgentConfig" {
  name  = "CWAgentConfig"
  type  = "String"
  value = <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/var/log/secure",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/var/log/httpd/access_log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/var/log/httpd/error_log",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
      "ImageId": "$${aws:ImageId}",
      "InstanceId": "$${aws:InstanceId}",
      "InstanceType": "$${aws:InstanceType}"
    },
    "metrics_collected": {
      "collectd": {
        "metrics_aggregation_interval": 60
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ],
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "used_percent",
          "inodes_free"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time",
          "write_bytes",
          "read_bytes",
          "writes",
          "reads"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "statsd": {
        "metrics_aggregation_interval": 60,
        "metrics_collection_interval": 10,
        "service_address": ":8125"
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF
}

# data "aws_ami" "amazon_linux_2023" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }
# }

resource "aws_security_group" "SSMAccess" {
  name        = "SSMAccess"
  vpc_id      = aws_vpc.VPC.id
  description = "Allow SSM access"

  ingress {
    description = "Allow HTTPS for SSM"
    from_port   = 443
    to_port     = 443
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
    Name = "SSMAccess"
  }
}

# resource "aws_instance" "WordpressEC2" {
#   ami                    = data.aws_ami.amazon_linux_2023.id
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.SNPUBA.id
#   iam_instance_profile   = aws_iam_instance_profile.WordpressInstanceProfile.name
#   vpc_security_group_ids = [aws_security_group.SGWordpress.id, aws_security_group.SSMAccess.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               systemctl start amazon-ssm-agent
#               systemctl enable amazon-ssm-agent
#               EOF

#   tags = {
#     Name = "WordpressEC2"
#   }
# }

data "aws_availability_zones" "available" {
  state = "available"
}