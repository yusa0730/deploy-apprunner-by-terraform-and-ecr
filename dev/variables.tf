variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "leadinfla"
}

variable "env" {
  description = "The environment (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The AWS region."
  type        = string
  default     = "ap-northeast-1"
}
