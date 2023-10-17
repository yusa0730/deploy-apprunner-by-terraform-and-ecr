resource "aws_iam_role" "apprunner_ecr_access" {
  name = "apprunner-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
  role       = aws_iam_role.apprunner_ecr_access.name
}

# Apprunner作成時にInvalidRequestException: Error in assuming access role
# 発生しないように10秒待つ
resource "time_sleep" "wait_10_seconds" {
  create_duration = "10s"

  triggers = {
    apprunner_access_arn = aws_iam_role.apprunner_ecr_access.arn
  }
}

resource "aws_iam_role" "apprunner_instance" {
  name = "${var.env}-${var.project_name}-apprunner-instance"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "tasks.apprunner.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_and_parameters_access" {
  name        = "AppRunnerSecretsAndParametersAccess"
  description = "Allow App Runner to access Secrets Manager and Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_and_parameters_access_policy_attach" {
  policy_arn = aws_iam_policy.secrets_and_parameters_access.arn
  role       = aws_iam_role.apprunner_instance.name
}
