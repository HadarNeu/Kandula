# Creating Target Group for public access
resource "aws_lb_target_group" "app_tg" {
  name       = "app-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = module.kandula-vpc.vpc_id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Attechement of target group to webservers
resource "aws_lb_target_group_attachment" "app_tg" {
  count = var.nginx_instances_count

  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
}

# Creating the actual Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "AppAlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    module.kandula-vpc.public_subnets_id[0],
    module.kandula-vpc.public_subnets_id[1]

  ]
}

# A listener to recieve incoming traffic
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
   name        = "alb_sg"
   vpc_id      = "${module.kandula-vpc.vpc_id}"

   # HTTP access - Traffic from internet
   ingress {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       # Restrict ingress to necessary IPs/ports.
       cidr_blocks = ["0.0.0.0/0"]
   }

  
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  

   tags = {
       Name = "alb_sg"
   }
}

output "lb_id" {
  description = "The ID and ARN of the load balancer we created"
  value       = try(aws_lb.app_alb.dns_name, "")
}

output "alb_dns" {
  description = "The DNS of the load balancer we created"
  value = aws_lb.app_alb.dns_name
}