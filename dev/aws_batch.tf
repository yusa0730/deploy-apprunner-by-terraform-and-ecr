resource "aws_batch_compute_environment" "main" {
  compute_environment_name = "${var.project_name}-${var.env}aws-batch-compute-environment"
  compute_resources {
    type = "Fargate"
    subnets = [
      aws_subnet.aws_batch_private_a.id
    ]
    security_group_ids = [aws_security_group.aws_batch_sg.id]
    max_vcpus          = 4
  }
  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch]

  tags = {
    Name      = "${var.project_name}-${var.env}-aws-batch-compute-environment"
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_batch_job_queue" "batch_queue" {
  name                 = "${var.project_name}-${var.env}-batch-queue"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.main.arn]

  tags = {
    Name      = "${var.project_name}-${var.env}-batch-queue"
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_batch_job_definition" "main" {
  name                  = "${var.project_name}-${var.env}-batch-job-def"
  type                  = "container"
  platform_capabilities = ["FARGATE"]

  container_properties = jsonencode({
    command = ["node", "index.js"],
    image   = "${aws_ecr_repository.aws_batch.repository_url}:latest",

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "${aws_cloudwatch_log_group.aws_batch.name}"
        "awslogs-region"        = "${var.region}"
        "awslogs-stream-prefix" = "aws-batch-job"
      }
    }

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "1"
      },
      {
        type  = "MEMORY"
        value = "2048"
      }
    ]
    jobRoleArn = "${aws_iam_role.batch_job_role.arn}"

    executionRoleArn = "${aws_iam_role.batch_task_execution_role.arn}"
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-batch-job-def"
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}
