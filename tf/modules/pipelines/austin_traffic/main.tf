resource "aws_glue_job" "import_raw_traffic_json" {
  name        = "${var.app_prefix}-import-raw-traffic-json"
  role_arn = var.glue_role.arn

  command {
    name            = "pythonshell"
    script_location = "s3://${var.data_bucket}/scripts/shell_job.py"
    python_version  = "3.9"
  }

  default_arguments = {
    "--TempDir" = "s3://${var.data_bucket}/tmp/",
    "--additional-python-modules" = "s3://${var.data_bucket}/dist/sample_pipelines-0.1.0-py3-none-any.whl",
    "--class" = "GlueApp",
    "--enable-continuous-cloudwatch-log" = "true",
    "--enable-glue-datacatalog" = "true",
    "--enable-job-insights" = "true",
    "--enable-metrics" = "true",
    "--enable-spark-ui" = "true",
    "--job-language" = "python",
    "--job_function" = "import_csv",
    "--job_module" = "sample_pipelines.traffic.raw",
    "--secret_id" = "${var.app_prefix}-data-secrets",
    "--spark-event-logs-path" = "s3://${var.data_bucket}/sparkHistoryLogs/"
  }
}

resource "aws_glue_job" "transform_traffic_raw_to_stage" {
  name        = "${var.app_prefix}-transform-traffic-raw-to-stage"
  role_arn = var.glue_role.arn
  glue_version = "3.0"

  command {
    name            = "glueetl"
    script_location = "s3://${var.data_bucket}/scripts/etl_job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir" = "s3://${var.data_bucket}/tmp/",
    "--additional-python-modules" = "s3://${var.data_bucket}/dist/sample_pipelines-0.1.0-py3-none-any.whl",
    "--class" = "GlueApp",
    "--enable-continuous-cloudwatch-log" = "true",
    "--enable-glue-datacatalog" = "true",
    "--enable-job-insights" = "true",
    "--enable-metrics" = "true",
    "--enable-spark-ui" = "true",
    "--job-language" = "python",
    "--job_function" = "transform_raw",
    "--job_module" = "sample_pipelines.traffic.stage",
    "--secret_id" = "${var.app_prefix}-data-secrets",
    "--spark-event-logs-path" = "s3://${var.data_bucket}/sparkHistoryLogs/"
  }
}

resource "aws_glue_crawler" "stage_traffic_crawler" {
  database_name = "${var.app_prefix}-stage"
  name          = "${var.app_prefix}-stage-traffic-crawler"
  role          = var.glue_crawler_role.arn

  s3_target {
    path = "s3://${var.data_bucket}/stage/sample/austin_traffic"
  }
}
