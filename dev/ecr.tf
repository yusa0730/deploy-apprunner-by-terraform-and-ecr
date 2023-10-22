resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-${var.env}-frontend-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-frontend-ecr",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-${var.env}-backend-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-backend-ecr",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}
