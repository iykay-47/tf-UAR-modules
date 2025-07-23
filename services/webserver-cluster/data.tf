# ==============================================================================
# DATA SOURCES - Getting existing AWS resources
# ==============================================================================
# Data sources let you fetch information about existing AWS resources
# This gets information about the default VPC (Virtual Private Cloud)

data "aws_vpc" "vpc-info" {
  default = true # Find the default VPC in this region
}

# This gets information about all subnets in the default VPC
# Subnets are smaller network segments within a VPC

data "aws_subnets" "subnet-info" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc-info.id] # Only get subnets from our VPC
  }
}

data "aws_security_group" "test" {
  filter
}

data "aws_security_groups" "name" {
  default = true  
}

# Read input from database 

# data "terraform_remote_state" "mysql-db" {
#   backend = "s3"

#   config = {
#     bucket = "${var.db-remote-state-bucket}"
#     region = "us-east-2"
#     key    = "${var.db-remote-state-key}"
#   }
# }

