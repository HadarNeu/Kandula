
resource "aws_instance" "prometheus_server" {
  count = 0
  # count= var.elastic_instances_count
  ami = data.aws_ami.ubuntu-ami.id
  instance_type = var.prometheus_instance_type
  key_name = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[count.index]
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.prometheus-server-sg.id]
  user_data            = file("${path.module}/scripts/prometheus-consul-user-data.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name

  tags = {
    Name = "prometheus-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "ec2"
    "service" = "prometheus"
    "consul" = "true"
  }

}

######Elastic SG############
resource "aws_security_group" "prometheus-server-sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "prometheus-server-sg-kandula"

  tags = {
    "Name" = "prometheus-server-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
  }
}

resource "aws_security_group_rule" "prometheus_grafana_access" {
  description       = "allow http access from anywhere"
  from_port         = 9090
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus-server-sg.id
  to_port           = 9090
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus-server-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus_consul_dns_access" {
  description       = "allow ssh access from anywhere"
  from_port         = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus-server-sg.id
  to_port           = 8600
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus_consul_rcp_access" {
  description       = "allow rcp access from anywhere- allow requests from agents"
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus-server-sg.id
  to_port           = 8300
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus_consul_serf_lan_access" {
  description       = "allow serf LAN access from anywhere- used to handle gossip"
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus-server-sg.id
  to_port           = 8301
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.prometheus-server-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

