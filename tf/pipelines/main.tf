module "austin_traffic_pipeline" {
  source = "./austin_traffic"

  app_prefix = var.app_prefix
  data_bucket = var.data_bucket
  etl_script_url = var.etl_script_url
  shell_script_url = var.shell_script_url
  wheel_file = var.wheel_file
  path_secret_id = var.path_secret_id
  secrets_id = var.secrets_id
  glue_role = var.glue_role
  glue_crawler_role = var.glue_crawler_role
}
