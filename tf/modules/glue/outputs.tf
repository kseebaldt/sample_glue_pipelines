output "glue_role" {
  value = aws_iam_role.glue_role
}

output "glue_crawler_role" {
  value = aws_iam_role.glue_crawler_role
}

output "stage_database" {
  value = aws_glue_catalog_database.stage_database
}
