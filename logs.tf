resource "aws_cloudwatch_log_group" "log_group" {
  name              = local.name
  retention_in_days = var.log_retention
  tags              = local.tags
}
