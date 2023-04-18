# locals "cluster_name" {
#   description = "[REQUIRED] the name of the EKS cluster"
#   default     = "opsschool-eks-hadar-wCthgH4i"
#   type        = string
# }
locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
  cluster_name = "opsschool-eks-hadar-wCthgH4i"
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

###TODO what is needed here?
variable "group1_instance_type" {
  description = "The type of the ec2"
  default     = "t3.medium"
  type        = string
}

variable "group2_instance_type" {
  description = "The type of the ec2"
  default     = "t3.large"
  type        = string
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance"
  default     = "jenkins-kandula"
  type        = string
}


