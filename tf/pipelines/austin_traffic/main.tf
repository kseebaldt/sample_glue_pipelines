module "import_raw_traffic_json" {
  source = "../../modules/shell_job"

  job_name = "${var.app_prefix}-import-raw-traffic-json"
  glue_role = var.glue_role
  shell_script_url = var.shell_script_url
  data_bucket = var.data_bucket
  wheel_file = var.wheel_file
  job_function = "import_csv"
  job_module = "sample_pipelines.traffic.raw"
  path_secret_id = var.path_secret_id
  secrets_id = var.secrets_id
}

module "transform_traffic_raw_to_stage" {
  source = "../../modules/etl_job"

  job_name = "${var.app_prefix}-transform-traffic-raw-to-stage"
  glue_role = var.glue_role
  etl_script_url = var.etl_script_url
  data_bucket = var.data_bucket
  wheel_file = var.wheel_file
  job_function = "transform_raw"
  job_module = "sample_pipelines.traffic.stage"
  path_secret_id = var.path_secret_id
  secrets_id = var.secrets_id
}

resource "aws_glue_crawler" "stage_traffic_crawler" {
  database_name = "${var.app_prefix}-stage"
  name          = "${var.app_prefix}-stage-traffic-crawler"
  role          = var.glue_crawler_role.arn

  s3_target {
    path = "s3://${var.data_bucket}/stage/sample/austin_traffic"
  }
}
