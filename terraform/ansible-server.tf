resource "aws_instance" "ansible_server" {
  count = var.ansible_instances_count
  ami           = data.aws_ami.ubuntu-ami.id
  instance_type = var.ansible_instance_type
  associate_public_ip_address = false
  subnet_id = module.kandula-vpc.private_subnets_id[count.index]

  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  key_name               = var.key_name

  user_data = file("${path.module}/scripts/ansible-consul-user-data.sh")

  tags = {
    "Name" = "ansible-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${module.kandula-vpc.vpc_name}"
  }
}