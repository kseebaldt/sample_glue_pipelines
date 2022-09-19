resource "aws_glue_job" "etl_job" {
  name        = var.job_name
  role_arn = var.glue_role.arn
  glue_version = "3.0"

  command {
    name            = "glueetl"
    script_location = var.etl_script_url
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir" = "s3://${var.data_bucket}/tmp/",
    "--additional-python-modules" = "s3://${var.data_bucket}/dist/${var.wheel_file}",
    "--class" = "GlueApp",
    "--enable-continuous-cloudwatch-log" = "true",
    "--enable-glue-datacatalog" = "true",
    "--enable-job-insights" = "true",
    "--enable-metrics" = "true",
    "--enable-spark-ui" = "true",
    "--job-language" = "python",
    "--job_function" = var.job_function,
    "--job_module" = var.job_module,
    "--path_secret_id" = var.path_secret_id,
    "--secrets_id" = var.secrets_id,
    "--spark-event-logs-path" = "s3://${var.data_bucket}/sparkHistoryLogs/"
  }
}
