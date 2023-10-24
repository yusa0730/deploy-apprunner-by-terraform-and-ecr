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

## AWS Batch
resource "aws_iam_role" "batch_service_role" {
  name = "${var.project_name}-${var.env}-batch-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "batch.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-batch-service-role",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy" "aws_batch" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "aws_batch" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = data.aws_iam_policy.aws_batch.arn
}

resource "aws_iam_role" "batch_task_execution_role" {
  name = "${var.project_name}-${var.env}-batch-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-batch-task-execution-role",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy" "batch_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_task_execution" {
  role       = aws_iam_role.batch_task_execution_role.id
  policy_arn = data.aws_iam_policy.batch_task_execution.arn
}

resource "aws_iam_role" "batch_job_role" {
  name = "${var.project_name}-${var.env}-batch-job-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-batch-job-role",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy" "batch_job" {
  name   = "${var.project_name}-${var.env}-batch-job-policy"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.batch_job_custom.json
}

data "aws_iam_policy_document" "batch_job_custom" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.aws_batch.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
    resources = [
      aws_ecr_repository.aws_batch.arn
    ]
  }
}

# IAM Role that EventBridge assumes
resource "aws_iam_role" "event_role" {
  name = "${var.project_name}-${var.env}-event-bridge-batch-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-event-bridge-batch-execution-role",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

# Add the permissions necessary for the EventBridge role
resource "aws_iam_role_policy_attachment" "event_role_permissions" {
  role       = aws_iam_role.event_role.name
  policy_arn = aws_iam_policy.event_policy.arn
}

resource "aws_iam_policy" "event_policy" {
  name        = "${var.project_name}-${var.env}-event-bridge-batch-policy"
  description = "Policy to allow EventBridge to start AWS Batch Jobs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "batch:SubmitJob"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-event-bridge-batch-policy",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}
