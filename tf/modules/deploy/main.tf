terraform {
  required_version = "~> 1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

resource "aws_iam_user" "deploy_user" {
  name = "${var.app_prefix}-deploy"

}

resource "aws_iam_policy" "deploy_policy" {
  name        = "${var.app_prefix}-deploy"
  description = "${var.app_prefix} Deploy Policy"
  policy = templatefile("${path.module}/policies/deploy_policy.json.tpl", { 
    data_bucket = var.data_bucket
  })
}

resource "aws_iam_user_policy_attachment" "deploy_attach" {
  user       = aws_iam_user.deploy_user.name
  policy_arn = aws_iam_policy.deploy_policy.arn
}

resource "aws_iam_access_key" "deploy_user_access_key" {
  user    = aws_iam_user.deploy_user.name
}

resource "github_actions_secret" "deploy_access_key_id" {
  repository       = var.github_repository
  secret_name      = "AWS_ACCESS_KEY_ID"
  plaintext_value  = aws_iam_access_key.deploy_user_access_key.id
}

resource "github_actions_secret" "deploy_secret_access_key" {
  repository       = var.github_repository
  secret_name      = "AWS_SECRET_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.deploy_user_access_key.secret
}

resource "github_actions_secret" "deploy_bucket" {
  repository       = var.github_repository
  secret_name      = "AWS_S3_BUCKET"
  plaintext_value  = var.data_bucket
}
