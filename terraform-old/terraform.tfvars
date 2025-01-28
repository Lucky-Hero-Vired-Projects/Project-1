# AWS Region
aws_region = "us-west-2"

# VPC Configuration
aws_vpc_cidr = "172.0.0.0/16"
aws_public_subnet_cidr = ["172.0.1.0/24", "172.0.2.0/24"]
aws_private_subnet_cidr = ["172.0.3.0/24", "172.0.4.0/24"]

# EKS Cluster Configuration
cluster_name = "lucky-eks-cluster"
cluster_version = "1.31" 
instance_types = ["t3.medium"]
min_size = 1
max_size = 3
desired_size = 1
ami_type = "AL2_x86_64"

# IAM roles and policies
role_name = "lucky-eks-role"
#node_group_role_arn = "" 

# # Security Settings
# vpc_security_group_ids = [] # Specify security group IDs if needed

# # Enable/Disable features
# enable_managed_node_groups = true
