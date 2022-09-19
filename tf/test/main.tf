terraform {
  backend "s3" {
    bucket         = "kurtis-test-state"
    dynamodb_table = "kurtis-test-lock-table"
    encrypt        = true
    key            = "test/terraform.tfstate"
    region         = "us-east-1"
  }
}

locals {
  app_prefix = "kurtis-test"
  wheel_file = "sample_pipelines-0.1.0-py3-none-any.whl"
}

module "buckets" {
  source = "../modules/buckets"

  app_prefix = local.app_prefix
}

module "glue" {
  source = "../modules/glue"

  app_prefix = local.app_prefix
  data_bucket = module.buckets.data_bucket
}

module "deploy" {
  source = "../modules/deploy"

  app_prefix = "kurtis-test"
  data_bucket = module.buckets.data_bucket
  github_repository = "sample_glue_pipelines"
}

module "pipelines" {
  source = "../pipelines"

  app_prefix = local.app_prefix
  data_bucket = module.buckets.data_bucket
  etl_script_url = module.glue.etl_script_url
  shell_script_url = module.glue.shell_script_url
  wheel_file = local.wheel_file
  path_secret_id = module.glue.path_secret_id
  secrets_id = module.glue.secrets_id
  glue_role = module.glue.glue_role
  glue_crawler_role = module.glue.glue_crawler_role
}
