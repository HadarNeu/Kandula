
resource "aws_instance" "elastic_server" {
  count= var.elastic_instances_count
  ami = data.aws_ami.ubuntu-ami.id
  instance_type = var.elastic_instance_type
  key_name = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[count.index]
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.elastic-server-sg.id]
  user_data            = file("${path.module}/scripts/elastic-consul-user-data.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "elastic-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "ec2"
    "service" = "elastic"
    "consul" = "true"
    "consul-agent" = "true"
  }

}

######Elastic SG############
resource "aws_security_group" "elastic-server-sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "elastic-server-sg-kandula"

  tags = {
    "Name" = "elastic-server-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
  }
}

resource "aws_security_group_rule" "elastic_api_acess" {
  description       = "allow http access from anywhere"
  from_port         = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 9200
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elastic_cluster_access" {
  description       = "allow http access from anywhere"
  from_port         = 9300
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 9300
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elastic_node_exporter_access" {
  description       = "allow http access from anywhere"
  from_port         = 9100
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 9100
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elastic_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elastic_consul_dns_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 8600
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elastic_consul_rcp_access" {
  description       = "allow rcp access from anywhere- allow requests from agents"
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 8300
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elastic_consul_serf_lan_access" {
  description       = "allow serf LAN access from anywhere- used to handle gossip"
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 8301
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elastic_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.elastic-server-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

