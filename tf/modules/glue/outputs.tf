output "glue_role" {
  value = aws_iam_role.glue_role
}

output "glue_crawler_role" {
  value = aws_iam_role.glue_crawler_role
}

output "stage_database" {
  value = aws_glue_catalog_database.stage_database
}

output "etl_script_url" {
  value = "s3://${var.data_bucket}/${aws_s3_object.etl_script.id}"
}

output "shell_script_url" {
  value = "s3://${var.data_bucket}/${aws_s3_object.shell_script.id}"
}
