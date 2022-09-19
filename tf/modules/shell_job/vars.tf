variable "job_name" {
  type = string
}

variable "glue_role" {
  type = object({
    arn = string
    name = string
  })
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

variable "job_function" {
  type = string
}

variable "job_module" {
  type = string
}

variable "path_secret_id" {
  type = string
}

variable "secrets_id" {
  type = string
}
