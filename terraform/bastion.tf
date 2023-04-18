# INSTANCES
resource "aws_instance" "bastion" {
    count                       = var.bastion_instances_count
    ami                         = data.aws_ami.ubuntu-ami.id
    instance_type               = var.bastion_instance_type
    key_name                    = var.key_name
    subnet_id                   = module.kandula-vpc.public_subnets_id[count.index]
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.nginx_instances_access.id]

    provisioner "file" {
      source      = "${var.key_location}"
      destination = "${var.key_destination}"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod 400 ${var.key_destination}",
      ]
    }
  tags = {
    "Name" = "bastion-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${module.kandula-vpc.vpc_name}"
  }
}
