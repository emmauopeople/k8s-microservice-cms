# Supplemental permissions required by AWS Load Balancer Controller v3.5.x.
# The original controller policy remains intact; this policy adds only actions
# introduced by newer controller releases.

resource "aws_iam_policy" "aws_load_balancer_controller_v3_supplement" {
  name        = "${var.cluster_name}-aws-load-balancer-controller-v3-supplement"
  description = "Supplemental IAM permissions for AWS Load Balancer Controller v3.5.x"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AdditionalEc2Discovery"
        Effect = "Allow"
        Action = [
          "ec2:GetCoipPoolUsage",
          "ec2:GetSecurityGroupsForVpc",
          "ec2:DescribeRouteTables"
        ]
        Resource = "*"
      },
      {
        Sid    = "ServerCertificateDiscovery"
        Effect = "Allow"
        Action = [
          "iam:ListServerCertificates",
          "iam:GetServerCertificate"
        ]
        Resource = "*"
      },
      {
        Sid    = "AdditionalElbDiscovery"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeCapacityReservation"
        ]
        Resource = "*"
      },
      {
        Sid    = "AdditionalTaggedElbMutation"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyListenerAttributes",
          "elasticloadbalancing:ModifyCapacityReservation",
          "elasticloadbalancing:ModifyIpPools"
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Sid    = "TagNewElbResources"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags"
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
        Condition = {
          StringEquals = {
            "elasticloadbalancing:CreateAction" = [
              "CreateTargetGroup",
              "CreateLoadBalancer"
            ]
          }
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Sid    = "AdditionalListenerAndWafMutation"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:SetRulePriorities"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_v3_supplement" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_v3_supplement.arn
}
