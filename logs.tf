resource "aws_cloudwatch_log_group" "log_group" {
  name              = local.name
  retention_in_days = 30
  tags              = local.tags
}
