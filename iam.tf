resource "aws_iam_role" "eks-master-role" {
  name = "eks-master-role"

  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOS
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-master-role.name
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-master-role.name
}

resource "aws_iam_role" "eks-node-role" {
  name = "eks-node-role"

  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOS
}

resource "aws_iam_policy" "route53-external-policy" {
  name   = "route53-external-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "route53-externaldns-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      #identifiersにEKSワーカーノードのarnをセットする。
      identifiers = ["${aws_iam_role.eks-node-role.arn}"]
    }
  }
}

resource "aws_iam_role" "route53-externaldns-controller" {
  name               = "route53-externaldns-controller"
  assume_role_policy = data.aws_iam_policy_document.route53-externaldns-policy.json
}

resource "aws_iam_role_policy_attachment" "route53-externaldns-attachment" {
  role       = aws_iam_role.route53-externaldns-controller.name
  policy_arn = aws_iam_policy.route53-external-policy.arn
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "ec2-container-registry-readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "ec2-role-for-ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_instance_profile" "eks-node-role-profile" {
  name = "eks-node-role-profile"
  role = aws_iam_role.eks-node-role.name
}
