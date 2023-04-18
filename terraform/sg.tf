######Jenkins SG############
resource "aws_security_group" "jenkins-servers-sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "jenkins-servers-sg"

  tags = {
    "Name" = "jenkins-servers-sg-${module.kandula-vpc.vpc_name}"
  }
}

resource "aws_security_group_rule" "jenkins_http_acess" {
  description       = "allow http access from anywhere"
  from_port         = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins-servers-sg.id
  to_port           = 8080
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins-servers-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_consul_dns_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins-servers-sg.id
  to_port           = 8600
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_consul_rcp_access" {
  description       = "allow rcp access from anywhere- allow requests from agents"
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins-servers-sg.id
  to_port           = 8300
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_consul_serf_lan_access" {
  description       = "allow serf LAN access from anywhere- used to handle gossip"
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins-servers-sg.id
  to_port           = 8301
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.jenkins-servers-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

#########Consul Server SG###########
resource "aws_security_group" "consul-servers-sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "consul-servers-sg"

  tags = {
    "Name" = "consul-servers-sg-${module.kandula-vpc.vpc_name}"
  }
}

resource "aws_security_group_rule" "consul_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.consul-servers-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_servers_dns_acess" {
  description       = "allow dns access from anywhere"
  from_port         = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.consul-servers-sg.id
  to_port           = 8600
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_servers_http_api" {
  description       = "allow http access from anywhere- consul API"
  from_port         = 8500
  protocol          = "tcp"
  security_group_id = aws_security_group.consul-servers-sg.id
  to_port           = 8500
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_servers_rcp_access" {
  description       = "allow rcp access from anywhere- allow requests from agents"
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.consul-servers-sg.id
  to_port           = 8300
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_servers_serf_lan_access" {
  description       = "allow serf LAN access from anywhere- used to handle gossip"
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.consul-servers-sg.id
  to_port           = 8301
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_servers_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.consul-servers-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

############Load Balancer SG#################

resource "aws_security_group" "alb_sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "alb-sg-kandula"

  tags = {
    "Name" = "alb-sg-${module.kandula-vpc.vpc_name}"
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

############Bastion SG#################

resource "aws_security_group" "bastion_sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "bastion-sg-kandula"

  tags = {
    "Name" = "bastion-sg-${module.kandula-vpc.vpc_name}"
  }
}

resource "aws_security_group_rule" "bastion_ssh_access" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.bastion_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

############Ansible SG#################

resource "aws_security_group" "ansible_sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "ansible-sg-kandula"

  tags = {
    "Name" = "ansible-sg-${module.kandula-vpc.vpc_name}"
  }
}

resource "aws_security_group_rule" "ansible_ssh_access" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ansible_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ansible_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ansible_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ansible_icmp_access" {
  description       = "allow icmp access from anywhere- Internet Control Message Protocol"
  from_port         = 8
  protocol          = "icmp"
  security_group_id = aws_security_group.ansible_sg.id
  to_port           = 0
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}