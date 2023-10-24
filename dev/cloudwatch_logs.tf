resource "aws_cloudwatch_log_group" "aws_batch" {
  name = "/aws-batch/${var.env}/job"

  tags = {
    Name      = "${var.project_name}-${var.env}-aws-batch-log"
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}
