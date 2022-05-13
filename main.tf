data "aws_subnets" "public" {
  filter {
    name = "tag:Name"
    values = ["default"]
  }
}
data "aws_vpc" "default" {
 default=true 
}
data "aws_security_group" "default" {
    vpc_id = data.aws_vpc.default.id
    filter {
      name = "tag:Name"
    values = ["default-vpc-default-security-group"]
    }
}

resource "aws_eks_cluster" "aws_eks_cluster" {
    name= "anupam"
    role_arn = "arn:aws:iam::554660509057:role/thinknyx_eks_cluster_role"
    vpc_config {
      subnet_ids=data.aws_subnets.public.ids
      endpoint_public_access = true
      security_group_ids = [data.aws_security_group.default.id]
    }
  tags = {
      Name = "anupam"
  }
}

resource "aws_eks_node_group" "node_group_1" {
    cluster_name = aws_eks_cluster.aws_eks_cluster.name
    node_group_name ="${aws_eks_cluster.aws_eks_cluster.name}-ng-1"
    node_role_arn = "arn:aws:iam::554660509057:role/thinknyx_eks_nodegroup_role"
    instance_types = ["t3.medium"]
    disk_size = 10
    scaling_config {
      desired_size=2
      min_size=2
      max_size=4
    }
  subnet_ids = data.aws_subnets.public.ids
  tags = {
      "Name"= "anupam"
   }
taint {
  key="name"
  value="${aws_eks_cluster.aws_eks_cluster.name}-ng-1"
  effect= "NO_SCHEDULE"
}
labels = {
    "name" = "${aws_eks_cluster.aws_eks_cluster.name}-ng-1"
 }
