##########Consul ALB ##############

# Creating the Application Load Balancer for Consul
resource "aws_lb" "consul_alb" {
  name               = "alb-consul-kandula"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    module.kandula-vpc.public_subnets_id[0],
    module.kandula-vpc.public_subnets_id[1]

  ]
  tags = {
    "Name" = "alb-consul-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "alb"
  }
}

# Creating Target Group for public access
resource "aws_lb_target_group" "consul_tg" {
  name       = "consul-tg-kandula"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = module.kandula-vpc.vpc_id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/ui/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    "Name" = "tg-consul-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "tg"
  }
}

# Attechement of target group to consul servers
resource "aws_lb_target_group_attachment" "consul_tg_attachment_1" {
  count = var.counsul_servers_count_subnet1

  target_group_arn = aws_lb_target_group.consul_tg.arn
  target_id        = aws_instance.consul_server_subnet1[count.index].id
  port             = 8500
}

# Attechement of target group to consul servers
resource "aws_lb_target_group_attachment" "consul_tg_attachment_2" {
  count = var.counsul_servers_count_subnet2

  target_group_arn = aws_lb_target_group.consul_tg.arn
  target_id        = aws_instance.consul_server_subnet2[count.index].id
  port             = 8500
}


# A listener to recieve incoming traffic
resource "aws_lb_listener" "consul_lb_listener" {
  load_balancer_arn = aws_lb.consul_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_tg.arn
  }

  tags = {
    "Name" = "alb-listener-consul-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "listener"
    "port" = "80"
  }
}

##########Jenkins ALB ##############

# Creating the Application Load Balancer
resource "aws_lb" "jenkins_alb" {
  count = 0 
  name               = "jenkins-alb-kandula"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    module.kandula-vpc.public_subnets_id[0],
    module.kandula-vpc.public_subnets_id[1]

  ]
  tags = {
    "Name" = "alb-jenkins-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "alb"
  }
}

# Creating Target Group for public access
resource "aws_lb_target_group" "jenkins_tg" {
  count = 0
  name       = "jenkins-tg-kandula"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = module.kandula-vpc.vpc_id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

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
  tags = {
    "Name" = "tg-jenkins-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "tg"
  }
}

# Attechement of target group to jenkins servers
resource "aws_lb_target_group_attachment" "jenkins_tg_attachment" {
  # count = var.jenkins_instances_count
  count = 0

  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.jenkins_server[count.index].id
  port             = 8080
}


# A listener to recieve incoming traffic
resource "aws_lb_listener" "jenkins_lb_listener" {
  count = 0
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  tags = {
    "Name" = "alb-listener-jenkins-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "listener"
    "port" = "80"
  }
}




############Load Balancer SG#################

resource "aws_security_group" "alb_sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "alb-sg-kandula"

  tags = {
    "Name" = "alb-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
  }
}
resource "aws_security_group_rule" "alb_http_access" {
  description       = "allow http access from anywhere"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.alb_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
