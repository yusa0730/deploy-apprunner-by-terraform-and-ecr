resource "aws_iam_role" "apprunner_ecr_access" {
  name = "${var.project_name}-${var.env}-apprunner-ecr-access-iam-role"

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

  tags = {
    Name      = "${var.project_name}-${var.env}-apprunner-ecr-access-iam-role",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
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

  tags = {
    Name      = "${var.project_name}-${var.env}-apprunner-instance-iam-role",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "secrets_and_parameters_access" {
  name        = "${var.project_name}-${var.env}-apprunner-secrets-and-parameters-access-policy"
  description = "Allow App Runner to access Secrets Manager and Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:PutParameter"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-apprunner-secrets-and-parameters-access-policy",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "secrets_and_parameters_access_policy_attach" {
  policy_arn = aws_iam_policy.secrets_and_parameters_access.arn
  role       = aws_iam_role.apprunner_instance.name
}

resource "aws_iam_policy" "rds_full_access" {
  name        = "${var.project_name}-${var.env}-rds-full-access-policy"
  description = "Full access to RDS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "rds:*",
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action   = "rds-db:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-rds-full-access-policy",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "rds_full_access_policy_attach" {
  policy_arn = aws_iam_policy.rds_full_access.arn
  role       = aws_iam_role.apprunner_instance.name
}

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.env}-ec2-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-ec2-iam-role",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.env}-iam-instance-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name      = "${var.project_name}-${var.env}-iam-instance-profile",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_session_manager_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
