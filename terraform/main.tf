module "eks" {
  source = "./modules/eks"

  cluster_name    = "my-eks-cluster-git"
  cluster_version = "1.29"
  region          = "us-east-1"

  vpc_id     = "vpc-03a8e4e41274f159c"
  subnet_ids = ["subnet-04ac84c7a273636eb", "subnet-020281564da7bbf11"]

  instance_type = "t3.medium"
  desired_size  = 2
  min_size      = 1
  max_size      = 3
}
