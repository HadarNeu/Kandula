# INSTANCES
resource "aws_instance" "jenkins-server" {
    count                       = var.nginx_instances_count
    ami                         = data.aws_ami.ubuntu-ami.id
    instance_type               = var.instance_type
    key_name                    = var.key_name
    subnet_id                   = module.kandula-vpc.public_subnets_id[count.index]
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.nginx_instances_access.id]
#   user_data                   = local.my-nginx-instance-userdata
    user_data = <<-EOF
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemtl start nginx
    sudo systemtl enable nginx
    echo "<h1>Welcome to Grandpas Whiskey</h1>" | sudo tee /var/www/html/index.html
    EOF

        
  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.nginx_root_disk_size
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.nginx_encrypted_disk_device_name
    volume_type = var.volumes_type
    volume_size = var.nginx_encrypted_disk_size
  }

  tags = {
    "Name" = "nginx-web-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${module.kandula-vpc.vpc_name}"
  }
}


