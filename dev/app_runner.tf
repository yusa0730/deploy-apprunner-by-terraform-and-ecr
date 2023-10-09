resource "aws_apprunner_service" "main" {
  service_name = "${var.env}-${var.project_name}-apprunner"

  source_configuration {
    authentication_configuration{
      access_role_arn = time_sleep.wait_10_seconds.triggers["apprunner_access_arn"]
    }

    image_repository {
      image_configuration {
        port = 3000
        runtime_environment_variables = {}
      }
      image_identifier = "${aws_ecr_repository.main.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
      cpu = 1024
      memory = 2048
      instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.nextjs_app.arn

  tags = {
    Name = "nextjs-app"
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "nextjs_app" {
  auto_scaling_configuration_name = "nextjs-app"
  max_concurrency                 = 100
  min_size                        = 1

  tags = {
    Name = "nextjs-app"
  }
}
