
# ==============================================================================
# SECURITY GROUPS - Network access control
# ==============================================================================
# Security groups act like virtual firewalls for your instances
# This security group is for our web server instances

resource "aws_security_group" "sg-terra-test-1" {
  name        = "${var.cluster-name}-instance"
  description = "Security group for instances"

  tags = {
    name = "${var.cluster-name}-alb-instance"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg-tg-inbound" {
  security_group_id = aws_security_group.sg-terra-test-1.id

  cidr_ipv4   = local.all_ips
  from_port   = var.sever-port
  ip_protocol = local.tcp_protocol
  to_port     = var.sever-port
}
resource "aws_vpc_security_group_egress_rule" "sg-tg-outbound" {
  security_group_id = aws_security_group.sg-terra-test-1.id

  cidr_ipv4   = local.all_ips
  from_port   = local.any_port
  ip_protocol = local.any_protocol
  to_port     = local.any_port
}


# Security group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "${var.cluster-name}-alb"
  description = "Security group for load balancer - allows port 80 inbound"

  tags = {
    name = "${var.cluster-name}-alb"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb-inbound" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = local.all_ips
  from_port   = local.http_port
  ip_protocol = local.tcp_protocol
  to_port     = local.http_port
}

resource "aws_vpc_security_group_egress_rule" "alb-outbound" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = local.all_ips
  from_port   = local.any_port
  ip_protocol = local.any_protocol
  to_port     = local.any_port
}



# resource "aws_security_group_rule" "alb-inbound" {

#   # INBOUND RULE: Allow incoming HTTP traffic on port 80
#   # This is where users will initially connect (standard web port)

#   type = "ingress"
#     from_port   = local.http_port # Port 80 (standard HTTP port)
#     to_port     = local.http_port # Same port
#     protocol    = local.tcp_protocol             # TCP protocol
#     cidr_blocks = local.all_ips     # Allow from anywhere
#     security_group_id = aws_security_group.alb.id

# }
# resource "aws_security_group_rule" "alb-outbound" {
#   # INBOUND RULE: Allow incoming HTTP traffic on port 80
#   # This is where users will initially connect (standard web port)

#   type = "egress"
#     from_port   = local.any_port 
#     to_port     = local.any_port
#     protocol    = local.any_protocol             # any protocal
#     cidr_blocks = local.all_ips     # Allow from anywhere
#     security_group_id = aws_security_group.alb.id

# }


# resource "aws_security_group_rule" "instance-inbound" {
#   # INBOUND RULE: Allow incoming HTTP traffic on port 80
#   # This is where users will initially connect (standard web port)

#   type = "ingress"
#     from_port   = var.sever-port            # Port 8080 (standard HTTP port)
#     to_port     = var.sever-port            # Same port
#     protocol    = local.tcp_protocol            # TCP protocol
#     cidr_blocks = local.all_ips     # Allow from anywhere
#     security_group_id = aws_security_group.sg-terra-test-1.id

# }
# resource "aws_security_group_rule" "instance-outbound" {
#   # INBOUND RULE: Allow incoming HTTP traffic on port 80
#   # This is where users will initially connect (standard web port)

#   type = "egress"
#     from_port   = local.http_port # Port 80 (standard HTTP port)
#     to_port     = local.http_port # Same port
#     protocol    = local.any_protocol             # TCP protocol
#     cidr_blocks = local.all_ips     # Allow from anywhere
#     security_group_id = aws_security_group.sg-terra-test-1.id

# }