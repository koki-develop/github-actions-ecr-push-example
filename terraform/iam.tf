data "aws_iam_openid_connect_provider" "main" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "main" {
  name               = "github-actions-ecr-push-example-role"
  assume_role_policy = data.aws_iam_policy_document.main_assume_role_policy.json
}

data "aws_iam_policy_document" "main_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.main.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role_policy" "main" {
  name   = "allow-ecr-push-image"
  role   = aws_iam_role.main.name
  policy = data.aws_iam_policy_document.main_policy.json
}

data "aws_iam_policy_document" "main_policy" {
  # ECR Login に必要
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # `docker push` に必要
  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
    ]
    resources = [aws_ecr_repository.main.arn]
  }
}
