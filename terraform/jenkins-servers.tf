
resource "aws_instance" "jenkins_server" {
  count= var.jenkins_instances_count
  ami = data.aws_ami.jenkins-server-ami.id
  instance_type = var.jenkins-instance-type
  key_name = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-servers-sg.id]
  user_data            = file("${path.module}/scripts/jenkins-consul-user-data.sh")
  iam_instance_profile   = aws_iam_instance_profile.jenkins-server.name

  tags = {
    Name = "jenkins-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "ec2"
    "service" = "jenkins"
    "consul" = "true"
  }

}

######Jenkins SG############
resource "aws_security_group" "jenkins-servers-sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "jenkins-servers-sg-kandula"

  tags = {
    "Name" = "jenkins-servers-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
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

