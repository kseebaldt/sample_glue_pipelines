variable "app_prefix" {
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

variable "etl_script_url" {
  type = string
}

variable "shell_script_url" {
  type = string
}

variable "data_bucket" {
  type = string
}

variable "wheel_file" {
  type = string
}

variable "path_secret_id" {
  type = string
}

variable "secrets_id" {
  type = string
}
