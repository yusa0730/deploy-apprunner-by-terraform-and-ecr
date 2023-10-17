resource "aws_apprunner_service" "main" {
  service_name = "${var.env}-${var.project_name}-apprunner"

  source_configuration {
    authentication_configuration {
      access_role_arn = time_sleep.wait_10_seconds.triggers["apprunner_access_arn"]
    }

    image_repository {
      image_configuration {
        port                          = 3000
        runtime_environment_variables = {}
      }
      image_identifier      = "${aws_ecr_repository.main.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu               = 1024
    memory            = 2048
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

resource "aws_apprunner_service" "backend" {
  service_name = "${var.env}-${var.project_name}-backend-apprunner"

  source_configuration {
    authentication_configuration {
      access_role_arn = time_sleep.wait_10_seconds.triggers["apprunner_access_arn"]
    }

    image_repository {
      image_configuration {
        port                          = 4000
        runtime_environment_variables = {}
      }
      image_identifier      = "${aws_ecr_repository.main.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.main.arn
    }

    ingress_configuration {
      is_publicly_accessible = false
    }
  }

  instance_configuration {
    cpu               = 1024
    memory            = 2048
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.fastify_app.arn

  tags = {
    Name = "fastify-app"
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "fastify_app" {
  auto_scaling_configuration_name = "fastify-app"
  max_concurrency                 = 100
  min_size                        = 1

  tags = {
    Name = "fastify-app"
  }
}

resource "aws_apprunner_vpc_ingress_connection" "main" {
  name        = "main"
  service_arn = aws_apprunner_service.backend.arn

  ingress_vpc_configuration {
    vpc_id          = aws_vpc.main.id
    vpc_endpoint_id = aws_vpc_endpoint.apprunner.id
  }

  tags = {
    Name = "ingress_connection"
  }
}

resource "aws_apprunner_vpc_connector" "main" {
  security_groups = [
    aws_security_group.from_api_gateway_to_lambda_sg.id
  ]
  subnets = [
    aws_subnet.lambda_private_a.id,
    aws_subnet.lambda_private_c.id
  ]
  tags               = {}
  tags_all           = {}
  vpc_connector_name = "vpc_connector_test"
}
