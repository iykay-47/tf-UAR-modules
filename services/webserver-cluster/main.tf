# ==============================================================================
# AWS TERRAFORM CONFIGURATION - Load Balancer with Auto Scaling Group
# ==============================================================================
# This configuration creates a scalable web application infrastructure on AWS
# with load balancing, auto scaling, and health monitoring capabilities.

# ==============================================================================
# LAUNCH TEMPLATE - Blueprint for Auto Scaling Group instances
# ==============================================================================
# Launch template defines how new instances should be configured
# This is used by the Auto Scaling Group to create identical instances

resource "aws_launch_template" "ubuntu-LC" {
  image_id               = "ami-0d1b5a8c13042c939" # Same Ubuntu AMI
  instance_type          = var.instance-type       # Same instance type
  vpc_security_group_ids = [aws_security_group.sg-terra-test-1.id]
  key_name = "iykay_key"

  # CORRECTED USER DATA - This version properly configures Apache for port 8080
  user_data = base64encode(templatefile("${path.module}/user-data.sh",{}))

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# AUTO SCALING GROUP - Automatically manages instance count
# ==============================================================================
# Auto Scaling Group automatically creates/destroys instances based on demand

resource "aws_autoscaling_group" "web-server-SG" {
  # Use our launch template to create instances
  launch_template {
    id      = aws_launch_template.ubuntu-LC.id
    version = "$Latest" # Always use the latest version of the template
  }

  # Deploy instances across multiple subnets for high availability
  vpc_zone_identifier = data.aws_subnets.subnet-info.ids

  # Instance count limits
  min_size                  = var.min-size # Always keep at least 2 instance running
  max_size                  = var.max-size # Never exceed 5 instances
  desired_capacity          = var.min-size # Optimal number of Instances
  health_check_grace_period = 300          # Wait 5 minutes before health checking new instances

  # Connect to load balancer target group
  target_group_arns = [aws_lb_target_group.asg-lb-tg.arn]
  health_check_type = "ELB" # Use load balancer health checks (more robust than EC2)

  wait_for_capacity_timeout = "10m"

  # Tag all instances created by this ASG
  tag {
    key                 = "name"
    value               = "${var.cluster-name}-asg"
    propagate_at_launch = true # Apply this tag to all instances
  }

  # This will force recreation of instances when launch template changes

  lifecycle {
    replace_triggered_by = [aws_launch_template.ubuntu-LC]
  }
}

