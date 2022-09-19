resource "aws_iam_role" "glue_role" {
  name        = "${var.app_prefix}-glue"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role" "glue_crawler_role" {
  name        = "AWSGlueServiceRole-${var.app_prefix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF  

  inline_policy {
    name   = "policy-8675309"
    policy = templatefile("${path.module}/policies/crawler_policy.json.tpl", { data_bucket = var.data_bucket })
  }
}

resource "aws_iam_policy" "glue_policy" {
  name        = "${var.app_prefix}-glue"
  description = "Glue Access Policy"
  policy = templatefile("${path.module}/policies/policy.json.tpl", { app_prefix = var.app_prefix, role_arn = aws_iam_role.glue_role.arn })
}

resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_glue_catalog_database" "stage_database" {
  name = "${var.app_prefix}-stage"

  create_table_default_permission {
    permissions = ["ALL"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_s3_object" "etl_script" {
  bucket = var.data_bucket
  key    = "scripts/etl_job.py"
  source = "${path.module}/scripts/etl_job.py"
  etag = filemd5("${path.module}/scripts/etl_job.py")
}

resource "aws_s3_object" "shell_script" {
  bucket = var.data_bucket
  key    = "scripts/shell_job.py"
  source = "${path.module}/scripts/shell_job.py"
  etag = filemd5("${path.module}/scripts/shell_job.py")
}
