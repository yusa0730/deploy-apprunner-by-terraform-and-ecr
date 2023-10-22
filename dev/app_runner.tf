resource "aws_apprunner_service" "backend" {
  depends_on = [
    aws_rds_cluster.aurora_cluster,
    aws_rds_cluster_instance.aurora_cluster_instance
  ]
  service_name = "${var.project_name}-${var.env}-backend-apprunner"

  source_configuration {
    authentication_configuration {
      access_role_arn = time_sleep.wait_10_seconds.triggers["apprunner_access_arn"]
    }

    image_repository {
      image_configuration {
        port = 8000
        runtime_environment_variables = {
          "APP_HOST"    = "0.0.0.0",
          "DB_HOST"     = "${aws_rds_cluster.aurora_cluster.endpoint}",
          "DB_PORT"     = "3306",
          "DB_USERNAME" = data.aws_ssm_parameter.db_username.value,
          "DB_NAME"     = data.aws_ssm_parameter.db_name.value,
          "DB_PASSWORD" = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)["DB_PASSWORD"]
        }
      }
      image_identifier      = "${aws_ecr_repository.backend.repository_url}:latest"
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

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.backend.arn

  tags = {
    Name      = "${var.project_name}-${var.env}-backend-apprunner",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "backend" {
  auto_scaling_configuration_name = "${var.project_name}-${var.env}-backend-config"
  max_concurrency                 = 100
  min_size                        = 1

  tags = {
    Name      = "${var.project_name}-${var.env}-backend-config",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_apprunner_vpc_ingress_connection" "main" {
  name        = "${var.env}-apprunner-vpc-ingress-connection"
  service_arn = aws_apprunner_service.backend.arn

  ingress_vpc_configuration {
    vpc_id          = aws_vpc.main.id
    vpc_endpoint_id = aws_vpc_endpoint.apprunner.id
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-apprunner-vpc-ingress-connection",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_apprunner_service" "frontend" {
  depends_on = [
    aws_apprunner_service.backend,
    aws_apprunner_vpc_ingress_connection.main
  ]
  service_name = "${var.project_name}-${var.env}-front-apprunner"

  source_configuration {
    authentication_configuration {
      access_role_arn = time_sleep.wait_10_seconds.triggers["apprunner_access_arn"]
    }

    image_repository {
      image_configuration {
        port = 3000
        runtime_environment_variables = {
          "BE_API_URL" = aws_apprunner_service.backend.service_url
        }
      }
      image_identifier      = "${aws_ecr_repository.frontend.repository_url}:latest"
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
      is_publicly_accessible = true
    }
  }

  instance_configuration {
    cpu               = 1024
    memory            = 2048
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.frontend.arn

  tags = {
    Name      = "${var.project_name}-${var.env}-frontend-apprunner",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "frontend" {
  auto_scaling_configuration_name = "${var.project_name}-${var.env}-frontend-config"
  max_concurrency                 = 100
  min_size                        = 1

  tags = {
    Name      = "${var.project_name}-${var.env}-frontend-config",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_apprunner_vpc_connector" "main" {
  security_groups = [
    aws_security_group.interface_sg.id
  ]
  subnets = [
    aws_subnet.interface_private_a.id,
    aws_subnet.interface_private_c.id
  ]
  vpc_connector_name = "vpc_connector_test"

  tags = {
    Name      = "${var.project_name}-${var.env}-vpc-connector",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_apprunner_custom_domain_association" "main" {
  domain_name = "ishizawa-aws-test.site"
  service_arn = aws_apprunner_service.frontend.arn
}
