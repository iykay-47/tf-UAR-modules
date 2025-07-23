# ==============================================================================
# VARIABLES SECTION
# ==============================================================================
# Variables allow you to customize your infrastructure without changing code


variable "sever-port" {
  description = "Ports for ingress traffic - [0] is for web server, [1] is for load balancer"
  type        = number
  default     = 8080
}

variable "cluster-name" {
description = "The name to use for all the cluster resources"
type = string
}

# variable "db-remote-state-bucket" {
# description = "The name of the S3 bucket for the database's remote state"
# type = string
# }

# variable "db-remote-state-key" {
# description = "The path for the database's remote state in S3"
# type = string
# }

variable "instance-type" {
description = "The type of EC2 Instances to run (e.g. t2.micro)"
type = string
}

variable "min-size" {
description = "The minimum number of EC2 Instances in the ASG"
type = number
}

variable "max-size" {
description = "The maximum number of EC2 Instances in the ASG"
type = number

}

locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = "0.0.0.0/0"
}