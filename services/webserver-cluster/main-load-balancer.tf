# ==============================================================================
# LOAD BALANCER COMPONENTS
# ==============================================================================
# Application Load Balancer - Distributes incoming traffic across instances

resource "aws_lb" "lb-example" {
  name               = "${var.cluster-name}-al-bal"
  load_balancer_type = "application"                    # Layer 7 load balancer (HTTP/HTTPS)
  subnets            = data.aws_subnets.subnet-info.ids # Deploy across multiple subnets
  security_groups    = [aws_security_group.alb.id]      # Apply ALB security group
}

# Target Group - Defines which instances receive traffic from load balancer
resource "aws_lb_target_group" "asg-lb-tg" {
  name     = "${var.cluster-name}-asg-target-group"
  port     = var.sever-port # Port 8080 (where Apache is running)
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc-info.id

  # Health check configuration - How the load balancer determines if instances are healthy
  health_check {
    path                = "/"    # Check the root path of the web server
    protocol            = "HTTP" # Use HTTP protocol for health checks
    matcher             = "200"  # Expect HTTP 200 (OK) response
    interval            = 30     # Check every 30 seconds
    timeout             = 10      # Wait 5 seconds for response
    healthy_threshold   = 2      # 2 successful checks = healthy
    unhealthy_threshold = 5      # 5 failed checks = unhealthy
  }
}

# Load Balancer Listener - Listens for incoming requests on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb-example.arn
  port              = local.http_port # Port 80 (standard HTTP port)
  protocol          = "HTTP"

  # Default action when no rules match - return 404
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404:Path not found"
      status_code  = 404
    }
  }
}

# Listener Rule - Forward all traffic to our target group
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100 # Rule priority (lower numbers = higher priority)

  # Condition: Match all paths (*)
  condition {
    path_pattern {
      values = ["*"] # Match any path
    }
  }

  # Action: Forward traffic to our target group (and thus to our instances)
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg-lb-tg.arn
  }
}
