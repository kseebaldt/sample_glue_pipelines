variable "app_prefix" {
  type = string
}

variable "data_bucket" {
  type = string
}

variable "etl_script_url" {
  type = string
}

variable "shell_script_url" {
  type = string
}

variable "glue_role" {
  type = object({
    arn = string
    name = string
  })
}

variable "glue_crawler_role" {
  type = object({
    arn = string
    name = string
  })
}

variable "stage_database" {
  type = object({
    arn = string
    id = string
  })
}