locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks-cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${local.cluster_name}"
KUBECONFIG

  eks_configmap = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node-role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks-master-role.arn
  version  = local.cluster_version

  vpc_config {
    security_group_ids     = [aws_security_group.cluster-master.id]
    subnet_ids             = aws_subnet.subnet.*.id
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-service-policy,
  ]
}

resource "aws_eks_node_group" "eks-cluster-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-cluster-node-group"
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = aws_subnet.subnet.*.id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}
