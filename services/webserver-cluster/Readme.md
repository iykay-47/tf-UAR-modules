### This shows an inproved version of the static web file dir including varriables 

# AWS Auto Scaling Web Application with Terraform

A complete Infrastructure as Code (IaC) solution for deploying a scalable web application on AWS using Terraform. This configuration creates a robust, auto-scaling web server infrastructure with load balancing and health monitoring.

## 🏗️ Architecture Overview

```
┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet  │───▶│  Load Balancer  │───▶│ Auto Scaling    │───▶│  Web Servers    │
│   (Port 80) │    │    (Port 80)    │    │     Group       │    │   (Port 8080)   │
└─────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                            │                       │                       │
                   ┌────────▼────────┐    ┌────────▼────────┐    ┌────────▼────────┐
                   │ Target Group    │    │ Launch Template │    │ Security Groups │
                   │ Health Checks   │    │ Instance Config │    │ Network Rules   │
                   └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Features

- **Auto Scaling**: Automatically manages 1-2 instances based on health
- **Load Balancing**: Distributes traffic evenly across healthy instances
- **High Availability**: Deploys across multiple availability zones
- **Health Monitoring**: Automatic instance replacement on failure
- **Security**: Configured security groups for web traffic
- **Infrastructure as Code**: Complete Terraform configuration

## 📋 Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 1.0+)
- AWS account with necessary permissions

## 🛠️ Quick Start

### 1. Clone and Initialize

```bash
git clone <your-repo>
cd terraform-aws-autoscaling
terraform init
```

### 2. Review and Deploy

```bash
# Review what will be created
terraform plan

# Deploy the infrastructure
terraform apply
```

### 3. Access Your Application

After deployment, Terraform will output the load balancer URL. Your web application will be available at:
```
http://your-load-balancer-dns-name.us-east-2.elb.amazonaws.com
```

## 📁 Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions (if separated)
├── outputs.tf             # Output definitions (if separated)
├── user-data.sh           # Instance startup script
└── README.md              # This file
```

## 🔧 Configuration

### Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `sever-port` | Ports for web server and load balancer | `[8080, 80]` | `list(number)` |

### Customization

To modify the configuration:

```hcl
# Change instance count
resource "aws_autoscaling_group" "web-server-SG" {
  min_size = 2  # Minimum instances
  max_size = 5  # Maximum instances
  # ...
}

# Change instance type
resource "aws_launch_template" "ubuntu-LC" {
  instance_type = "t3.small"  # Larger instance
  # ...
}
```

## 🔍 Components

### Auto Scaling Group
- **Min Size**: 1 instance
- **Max Size**: 2 instances
- **Health Check**: ELB-based with 5-minute grace period
- **Distribution**: Across all available subnets

### Load Balancer
- **Type**: Application Load Balancer (Layer 7)
- **Scheme**: Internet-facing
- **Health Check**: HTTP on port 8080, path "/"
- **Health Check Frequency**: Every 30 seconds

### Security Groups
- **Web Server SG**: Allows inbound port 8080, outbound all
- **Load Balancer SG**: Allows inbound port 80, outbound all

### Launch Template
- **AMI**: Ubuntu 20.04 LTS (ami-0d1b5a8c13042c939)
- **Instance Type**: t2.micro (free tier eligible)
- **User Data**: Automated Apache installation and configuration

## 🎯 User Data Script

The launch template uses the following startup script:

```bash
#!/bin/bash
# Update system packages
apt-get update
apt-get install -y apache2

# Configure Apache for port 8080
sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf

# Create simple web page
echo "Hello World. I am running on Amazon ip $(hostname -I)" > /var/www/html/index.html

# Start Apache
systemctl restart apache2
systemctl enable apache2
```

## 🔐 Security

### Network Security
- Security groups implement least-privilege access
- Load balancer accepts traffic only on port 80
- Web servers accept traffic only on port 8080
- All outbound traffic allowed for updates and dependencies

### Best Practices Implemented
- Launch template with `create_before_destroy` lifecycle
- Security groups with explicit ingress/egress rules
- Health checks with appropriate thresholds
- Multi-AZ deployment for high availability

## 📊 Monitoring

### Health Checks
- **Target Group Health**: HTTP 200 response on port 8080
- **Check Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy Threshold**: 2 consecutive successes
- **Unhealthy Threshold**: 5 consecutive failures

### AWS Console Monitoring
- **EC2 Dashboard**: Instance status and metrics
- **Load Balancer**: Target group health and request metrics
- **Auto Scaling**: Scaling activities and group status

## 🚨 Troubleshooting

### Common Issues

#### Unhealthy Instances
```bash
# Check if Apache is running on the correct port
curl localhost:8080

# Check Apache error logs
sudo tail -f /var/log/apache2/error.log

# Check user data execution
sudo cat /var/log/cloud-init-output.log
```

#### Load Balancer Issues
```bash
# Verify security group rules
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

# Check target group health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...
```

#### Auto Scaling Issues
```bash
# Check scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name web-server-SG
```

### Debug Commands

```bash
# SSH into instance (if key pair configured)
ssh -i your-key.pem ubuntu@<instance-ip>

# Check instance user data
curl http://169.254.169.254/latest/user-data

# Check instance metadata
curl http://169.254.169.254/latest/meta-data/
```

## 📈 Scaling

### Manual Scaling
```bash
# Update desired capacity
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name web-server-SG \
  --desired-capacity 2
```

### Automatic Scaling Policies
To add CPU-based scaling:

```hcl
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web-server-SG.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-server-SG.name
  }
}
```

## 💰 Cost Optimization

### Free Tier Resources
- **t2.micro instances**: 750 hours/month free
- **Application Load Balancer**: 750 hours/month free
- **Data Transfer**: 15 GB/month free

### Cost Monitoring
```bash
# Estimate monthly costs
aws ce get-cost-and-usage \
  --time-period Start=2025-01-01,End=2025-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## 🔄 Lifecycle Management

### Updates
```bash
# Update infrastructure
terraform plan
terraform apply

# Update user data only
terraform apply -target=aws_launch_template.ubuntu-LC
```

### Cleanup
```bash
# Destroy all resources
terraform destroy
```

### State Management
```bash
# View current state
terraform state list

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0
```

## 🚀 Production Enhancements

### SSL/HTTPS
```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb-example.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg-lb-tg.arn
  }
}
```

### Database Integration
```hcl
resource "aws_db_instance" "database" {
  identifier             = "myapp-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "myapp"
  username               = "admin"
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true
}
```

### Monitoring and Logging
```hcl
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/myapp"
  retention_in_days = 7
}
```

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Auto Scaling User Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/)
- [AWS Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [AWS Security Groups Guide](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
- Check the troubleshooting section above
- Review AWS documentation
- Open an issue in this repository
- Contact AWS support for service-specific issues

---

**Note**: This configuration is designed for learning and development purposes. For production use, consider implementing additional security measures, monitoring, and backup strategies.