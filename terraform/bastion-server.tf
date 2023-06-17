# INSTANCES
resource "aws_instance" "bastion" {
    count                       = var.bastion_instances_count
    ami                         = data.aws_ami.ubuntu-ami.id
    instance_type               = var.bastion_instance_type
    key_name                    = var.key_name
    subnet_id                   = module.kandula-vpc.public_subnets_id[count.index]
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

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
    "Name" = "bastion-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "ec2"
    "service" = "bastion"
    "consul" = "false"  
  }
}



############Bastion SG#################

resource "aws_security_group" "bastion_sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "bastion-sg-kandula"

  tags = {
    "Name" = "bastion-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
  }
}

resource "aws_security_group_rule" "bastion_ssh_access" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["212.199.61.110/32"]
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