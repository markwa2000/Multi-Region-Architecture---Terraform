terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
###########Vpc_Creation############

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "mum_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "mum-vpc"
  }
}

resource "aws_internet_gateway" "mum_igw" {
  vpc_id = aws_vpc.mum_vpc.id
  tags = {
    Name = "mum-igw"
  }
}


resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.mum_vpc.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidr)
  vpc_id                  = aws_vpc.mum_vpc.id
  cidr_block              = element(var.private_subnet_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name = "mum-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "mum-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mum_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mum_igw.id
  }
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.mum_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

##########LoadBalancer##########

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.mum_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.mum_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "mum-alb" {
  name               = "mum-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.private[*].id

  enable_deletion_protection = true

  /* access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = true
  } */
  tags = {
    Name = "mum-alb"
  }
}



resource "aws_db_subnet_group" "mum_db_subnet_group" {
  name       = "mum-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "rdssubnet-group"
  }
}

resource "aws_security_group" "mum_db_sg" {
  name_prefix = "mum-db-sg-"
  description = "DB_securitygroup"
  vpc_id      = aws_vpc.mum_vpc.id
  # Define security group rules for your RDS instance here
  ingress {
    from_port   = 3306  # MySQL port
    to_port     = 3306  # MySQL port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your desired source IP or CIDR range
  }
}

resource "aws_db_instance" "mum_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "mum-exampledb"
  username             = "dbusername" 
  password             = "dbpassword"
  db_subnet_group_name    = aws_db_subnet_group.mum_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.mum_db_sg.id]
  skip_final_snapshot  = true
}

#########EKS Cluster############

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id                         = aws_vpc.mum_vpc.id
  subnet_ids                     = aws_subnet.private[*].id
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }

    two = {
      name = "node-group-2"

      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
    three = {
      name = "node-group-3"

      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.5.2-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

########### This is the creation of an WAFv2 (Web ACL) and a example rate limit rule

resource "aws_wafv2_web_acl" "my_web_acl" {
  name  = "my-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimit"
    priority = 1

    action {
      block {}
    }

    statement {

      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 500
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "my-web-acl"
    sampled_requests_enabled   = false
  }
}

########### This is the association code

resource "aws_wafv2_web_acl_association" "web_acl_association_my_lb" {
  resource_arn = aws_lb.mum-alb.arn
  web_acl_arn  = aws_wafv2_web_acl.my_web_acl.arn
}