resource "aws_instance" "ansible_server" {
  count = var.ansible_instances_count
  ami           = data.aws_ami.ubuntu-ami.id
  instance_type = var.ansible_instance_type
  # associate_public_ip_address = false
  # subnet_id = module.kandula-vpc.private_subnets_id[count.index]
  subnet_id                   = module.kandula-vpc.public_subnets_id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ansible-server.name
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  user_data = file("${path.module}/scripts/ansible-consul-user-data.sh")
  provisioner "file" {
    source      = "${var.key_location}"
    destination = "${var.key_destination}"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = "${self.public_ip}"
    private_key = file("${var.key_location}")
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ${var.key_destination}",
    ]
  }
  tags = {
    "Name" = "ansible-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "ec2"
    "service" = "ansible"
    "consul" = "true"
  }
}



############Ansible SG#################

resource "aws_security_group" "ansible_sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "ansible-sg-kandula"

  tags = {
    "Name" = "ansible-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
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

resource "aws_security_group_rule" "ansible_node_expoter_access" {
  description       = "allow http access from anywhere"
  from_port         = 9100
  protocol          = "tcp"
  security_group_id = aws_security_group.ansible_sg.id
  to_port           = 9100
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}