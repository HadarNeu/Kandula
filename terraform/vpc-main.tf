module "kandula-vpc" {
    source = "./vpc-module"
    cluster_name = local.cluster_name
    vpc_name = "Consul-VPC"
    
}