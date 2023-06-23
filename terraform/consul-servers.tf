resource "aws_instance" "consul_server_subnet1" {
  count = var.counsul_servers_count_subnet1
  ami           = data.aws_ami.ubuntu-ami.id
  instance_type = var.consul_instance_type
  key_name      = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[0]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name

  vpc_security_group_ids = [aws_security_group.consul-servers-sg.id]
  user_data            = file("${path.module}/scripts/consul-server-user-data.sh")

  tags = {
    Name = "consul-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    consul = "true"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "ec2"
    "service" = "consul-server"
  }

}

resource "aws_instance" "consul_server_subnet2" {
  count = var.counsul_servers_count_subnet2
  ami           = data.aws_ami.ubuntu-ami.id
  instance_type = var.consul_instance_type
  key_name      = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[1]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  vpc_security_group_ids = [aws_security_group.consul-servers-sg.id]
  user_data            = file("${path.module}/scripts/consul-server-user-data.sh")

  tags = {
    Name = "consul-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    consul = "true"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "ec2"
    "service" = "consul-server"
  }
}


#########Consul Server SG###########
resource "aws_security_group" "consul-servers-sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "consul-servers-sg-kandula"

  tags = {
    "Name" = "consul-servers-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
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