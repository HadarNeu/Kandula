#########REQUIRED############
variable "rds_password" {
  description = "The admin password for the rds, required - SECRET"
  default     = null
  type        = string
}

variable "aws_profile" {
  description = "The profile of the credentials"
  default     = null
  type        = string
}

########GENERAL################
variable "aws_region" {
  default = "us-west-2"
  type    = string
}

variable "project_name" {
  description = "The key name of the project"
  default     = "kandula"
  type        = string
}


variable "key_name" {
  description = "The key name of the Key Pair to use for the instance"
  default     = "jenkins-kandula"
  type        = string
}

variable "ubuntu_account_number" {
  description = "The AWS account number Canonial -offical Ubuntu Images"
  default     = "099720109477"
  type        = string
}

variable "ubuntu_version" {
  description = "The version of the offical Ubuntu Images"
  default     = "20.04"
  type        = string
}

variable "key_location" {
  description = "The ssh key local location to transfer to our server"
  default     = "/home/ubuntu/.ssh/jenkins-kandula.pem"
  type        = string
}

variable "key_destination" {
  description = "The ssh key wanted destination on the ec2"
  default     = "/home/ubuntu/.ssh/jenkins-kandula.pem"
  type        = string
}

variable "vpn_endpoint" {
  description = "The vpn endpoint"
  default     = "212.199.61.110/32"
  type        = string
}


########JENKINS################
variable "jenkins-ami-name" {
  description = "The name of the pre-configured Jenkins ami"
  default = "jenkins-server-ami-kandula-1.3"
  type = string
}

variable "jenkins-instance-type" {
  description = "The type of the Jenkins Server ec2"
  default = "t3.small"
  type = string
}

variable "jenkins_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "jenkins-ui-url" {
  description = "The A record used for jenkins UI"
  default     = "jenkins.hadar.infitest.net"
  type        = string
}

########BASTION################
variable "bastion_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "bastion_instance_type" {
  description = "The type of the ec2"
  default     = "t2.micro"
  type        = string
}


########CONSUL################
variable "counsul_servers_count_subnet1" {
  description = "The number of consul servers instances to create"
  default     = 2
}

variable "counsul_servers_count_subnet2" {
  description = "The number of consul servers instances to create"
  default     = 1
}

variable "consul_instance_type" {
  description = "The type of the ec2"
  default     = "t2.micro"
  type        = string
}

variable "consul-ui-url" {
  description = "The A record used for jenkins UI"
  default     = "consul.hadar.infitest.net"
  type        = string
}

########ANSIBLE################
variable "ansible_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "ansible_instance_type" {
  description = "The type of the ec2"
  default     = "t3.small"
  type        = string
}

########ELK################
variable "elk_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "elk_instance_type" {
  description = "The type of the ec2"
  default     = "t3.small"
  type        = string
}

########FLUENTD################
variable "fluentd_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "fluentd_instance_type" {
  description = "The type of the ec2"
  default     = "t3.small"
  type        = string
}


########GRAFANA################
variable "grafana_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "grafana_instance_type" {
  description = "The type of the ec2"
  default     = "t3.small"
  type        = string
}

########PROMETHEUS################
variable "prometheus_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "prometheus_instance_type" {
  description = "The type of the ec2"
  default     = "t3.small"
  type        = string
}


