module "buckets" {
  source = "../buckets"

  app_prefix = var.app_prefix
}

module "glue" {
  source = "../glue"

  app_prefix = var.app_prefix
  data_bucket = module.buckets.data_bucket
}

module "austin_traffic_pipeline" {
  source = "./austin_traffic"

  app_prefix = var.app_prefix
  data_bucket = module.buckets.data_bucket
  etl_script_url = module.glue.etl_script_url
  shell_script_url = module.glue.shell_script_url
  path_secret_id = module.glue.path_secret_id
  secrets_id = module.glue.secrets_id
  glue_role = module.glue.glue_role
  glue_crawler_role = module.glue.glue_crawler_role
  stage_database = module.glue.stage_database
}
