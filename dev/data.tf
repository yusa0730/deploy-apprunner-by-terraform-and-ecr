data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "example" {
  name = "dev/secret/apprunner"
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = data.aws_secretsmanager_secret.example.id
}

data "aws_ssm_parameter" "db_username" {
  name = "db_user_name"
}

data "aws_ssm_parameter" "db_name" {
  name = "db_name"
}

output "db_password" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)["DB_PASSWORD"]
  sensitive = true
}
