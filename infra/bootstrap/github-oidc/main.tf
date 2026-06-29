data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

locals {
  github_repo_full_name = "${var.github_owner}/${var.github_repo}"

  allowed_subjects = [
    "repo:${local.github_repo_full_name}:ref:refs/heads/main",
    "repo:${local.github_repo_full_name}:ref:refs/heads/feature/*",
    "repo:${local.github_repo_full_name}:ref:refs/heads/release/*"
  ]

  ecr_repository_arns = [
    for repo_name in var.ecr_repository_names :
    "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${repo_name}"
  ]
}

resource "aws_iam_role" "github_actions" {
  name        = var.github_actions_role_name
  description = "IAM role assumed by GitHub Actions using OIDC for ${local.github_repo_full_name}."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGitHubActionsOIDCAssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.allowed_subjects
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_ecr" {
  name        = "${var.github_actions_role_name}-ecr-policy"
  description = "Allows GitHub Actions to authenticate to ECR and push images for the CMS services."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowECRAuthorizationToken"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "AllowPushPullToProjectRepositories"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = local.ecr_repository_arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}
