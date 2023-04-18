variable "cluster_name" {
  description = "[REQUIRED] the name of the EKS cluster"
  default     = null
  type        = string
}

variable "vpc-name" {
  description = "[REQUIRED] the name of the VPC"
  default     = "Kandula-VPC"
  type        = string
}

variable "aws_region" {
  default = "us-west-2"
  type    = string
}

variable "kubernetes_version" {
  default = 1.24
  description = "kubernetes version"
}

locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
  # cluster_name = "kandula-opsschool-cluster"
}

###TODO what is needed here?
variable "instance_type" {
  description = "The type of the ec2"
  default     = "t2.micro"
  type        = string
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance"
  default     = "jenkins-kandula"
  type        = string
}

variable "ubuntu_account_number" {
  description = "The AWS account number of the offical Ubuntu Images"
  default     = "099720109477"
  type        = string
}

variable "ubuntu_version" {
  description = "The version of the offical Ubuntu Images"
  default     = "20.04"
  type        = string
}

variable "bastion_instances_count" {
  description = "The number of bastion instances to create"
  default     = 1
}

variable "counsul_servers_count_subnet1" {
  description = "The number of consul servers instances to create"
  default     = 2
}

variable "counsul_servers_count_subnet2" {
  description = "The number of consul servers instances to create"
  default     = 1
}

variable "DB_instances_count" {
  description = "The number of DB instances to create"
  default     = 2
}

variable "nginx_root_disk_size" {
  description = "The size of the root disk"
  default     = 10
}

variable "nginx_encrypted_disk_size" {
  description = "The size of the secondary encrypted disk"
  default     = 10
}

variable "nginx_encrypted_disk_device_name" {
  description = "The name of the device of secondary encrypted disk"
  default     = "xvdh"
  type        = string
}

variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default     = "gp2"
}

variable "owner_tag" {
  description = "The owner tag will be applied to every resource in the project through the 'default variables' feature"
  default     = "Ops-School"
  type        = string
}

variable "purpose_tag" {
  default = "Whiskey"
  type    = string
}

variable "kubernetes_version" {
  default = 1.24
  description = "kubernetes version"
}


locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
  # cluster_name = "kandula-opsschool-cluster"
}

locals {
  cluster_name = "opsschool-eks-hadar-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}