# EventBridge Event Rule
resource "aws_cloudwatch_event_rule" "main" {
  name        = "${var.project_name}-${var.env}-event-rule"
  description = "${var.project_name}-${var.env}-event-rule"

  # schedule_expression = "cron(30 12 ? * 6#1 *)"
  schedule_expression = "cron(0/5 * * * ? *)"

  tags = {
    Name      = "${var.project_name}-${var.env}-event-rule"
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

# Target that links the Event Rule to the AWS Batch Job
resource "aws_cloudwatch_event_target" "main" {
  rule     = aws_cloudwatch_event_rule.main.name
  arn      = aws_batch_job_queue.batch_queue.arn
  role_arn = aws_iam_role.event_role.arn # A role that EventBridge can assume to launch the Batch Job

  batch_target {
    job_name       = "${var.project_name}-${var.env}-job"
    job_definition = aws_batch_job_definition.main.name
  }
}
