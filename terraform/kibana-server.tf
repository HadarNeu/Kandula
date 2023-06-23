
# resource "aws_instance" "kibana_server" {
#   count= var.kibana_instances_count
#   ami = data.aws_ami.ubuntu-ami.id
#   instance_type = var.kibana_instance_type
#   key_name = var.key_name
#   subnet_id                   = module.kandula-vpc.private_subnets_id[count.index]
#   associate_public_ip_address = false
#   vpc_security_group_ids      = [aws_security_group.kibana-server-sg.id]
#   user_data            = file("${path.module}/scripts/kibana-consul-user-data.sh")
#   iam_instance_profile   = aws_iam_instance_profile.consul-join.name
#   metadata_options {
    # http_endpoint = "enabled"
#       instance_metadata_tags = "enabled"
#   }

#   tags = {
#     Name = "kibana-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
#     "project" = "kandula"
#     "owner" = "hadar"
#     "env" = "prd"
#     "resource" = "ec2"
#     "service" = "kibana"
#     "consul" = "true"
    # "consul-agent" = "true"
#   }

# }

# ######Elastic SG############
# resource "aws_security_group" "kibana-server-sg" {
#   vpc_id = module.kandula-vpc.vpc_id
#   name   = "kibana-server-sg-kandula"

#   tags = {
#     "Name" = "kibana-server-sg-${var.project_name}"
#     "project" = "kandula"
#     "owner" = "hadar"
#     "env" = "prd"
#     "resource" = "sg"
#   }
# }

# resource "aws_security_group_rule" "kibana_elastic_access" {
#   description       = "allow http access from anywhere"
#   from_port         = 5601
#   protocol          = "tcp"
#   security_group_id = aws_security_group.kibana-server-sg.id
#   to_port           = 5601
#   type              = "ingress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }


# resource "aws_security_group_rule" "kibana_ssh_access" {
#   description       = "allow ssh access from anywhere"
#   from_port         = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.kibana-server-sg.id
#   to_port           = 22
#   type              = "ingress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "kibana_consul_dns_access" {
#   description       = "allow ssh access from anywhere"
#   from_port         = 8600
#   protocol          = "tcp"
#   security_group_id = aws_security_group.kibana-server-sg.id
#   to_port           = 8600
#   type              = "ingress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "kibana_consul_rcp_access" {
#   description       = "allow rcp access from anywhere- allow requests from agents"
#   from_port         = 8300
#   protocol          = "tcp"
#   security_group_id = aws_security_group.kibana-server-sg.id
#   to_port           = 8300
#   type              = "ingress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "kibana_consul_serf_lan_access" {
#   description       = "allow serf LAN access from anywhere- used to handle gossip"
#   from_port         = 8301
#   protocol          = "tcp"
#   security_group_id = aws_security_group.kibana-server-sg.id
#   to_port           = 8301
#   type              = "ingress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "kibana_outbound_anywhere" {
#   description       = "allow outbound traffic to anywhere"
#   from_port         = 0
#   protocol          = "-1"
#   security_group_id = aws_security_group.kibana-server-sg.id
#   to_port           = 0
#   type              = "egress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

