data "template_file" "ecs_task_stopped" {
  template = file("${path.module}/alerts/ecs_task_stopped.json")

  vars = {
    cluster_arn = aws_ecs_cluster.cluster.arn
  }
}

resource "aws_sns_topic" "events" {
  name = local.name
  tags = local.tags
}

// TODO: as soon as CWE Service / ServiceEvent also filter on
// "unable to place a task" messages in ServiceEvent instances
//
// see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_Service.html
resource "aws_cloudwatch_event_rule" "ecs_task_stopped" {
  description   = "${local.name} Essential container in task exited"
  event_pattern = data.template_file.ecs_task_stopped.rendered
  name          = "${local.name}-task-stopped"
  tags          = local.tags
}

resource "aws_cloudwatch_event_target" "ecs_task_stopped" {
  arn  = aws_sns_topic.events.arn
  rule = aws_cloudwatch_event_rule.ecs_task_stopped.name
}
