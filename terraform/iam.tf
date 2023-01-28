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
