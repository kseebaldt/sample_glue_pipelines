resource "aws_glue_job" "shell_job" {
  name        = var.job_name
  role_arn = var.glue_role.arn

  command {
    name            = "pythonshell"
    script_location = var.shell_script_url
    python_version  = "3.9"
  }

  default_arguments = {
    "--TempDir" = "s3://${var.data_bucket}/tmp/",
    "--extra-py-files" = "s3://${var.data_bucket}/dist/${var.wheel_file}",
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
