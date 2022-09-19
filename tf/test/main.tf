terraform {
  backend "s3" {
    bucket         = "kurtis-test-state"
    dynamodb_table = "kurtis-test-lock-table"
    encrypt        = true
    key            = "test/terraform.tfstate"
    region         = "us-east-1"
  }
}

module "pipelines" {
  source = "../modules/pipelines"

  app_prefix = "kurtis-test"
}
