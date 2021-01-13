locals {
  # even if it might be obvious for most people:
  # do not reword the content of these variables
  datadog_enable          = length(var.datadog_api_key) > 0 ? 1 : 0
  datadog_name            = "datadog-agent"
  datadog_log_pointer_dir = "/opt/datadog-agent/run/"
}

data "template_file" "definition" {
  template = file("${path.module}/datadog/definition.json")

  vars = {
    datadog_name = local.datadog_name
    dd_api_key   = var.datadog_api_key
    squad        = var.squad
    environment  = var.environment
  }
}

data "aws_iam_policy_document" "agent_trust_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "ec2.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "agent_policy" {
  statement {
    actions = [
      "ecs:RegisterContainerInstance",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Submit*",
      "ecs:Poll",
      "ecs:StartTask",
      "ecs:StartTelemetrySession",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "agent_policy" {
  count  = local.datadog_enable
  name   = "${local.datadog_name}-policy"
  policy = data.aws_iam_policy_document.agent_policy.json
}

resource "aws_iam_role" "agent_role" {
  count              = local.datadog_enable
  name               = "${local.datadog_name}-ecs"
  assume_role_policy = data.aws_iam_policy_document.agent_trust_policy.json
  tags               = local.tags
}

resource "aws_iam_instance_profile" "agent_profile" {
  count = local.datadog_enable
  name  = local.datadog_name
  role  = aws_iam_role.agent_role[0].name
}

resource "aws_iam_role_policy_attachment" "agent_role_default" {
  count      = local.datadog_enable
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.agent_role[0].name
}

resource "aws_iam_role_policy_attachment" "agent_role_attachment" {
  count      = local.datadog_enable
  policy_arn = aws_iam_policy.agent_policy[0].arn
  role       = aws_iam_role.agent_role[0].name
}

resource "aws_ecs_task_definition" "agent_definition" {
  count      = local.datadog_enable
  depends_on = [aws_iam_role.agent_role]
  tags       = merge(local.tags, {type = "operations"})

  container_definitions = data.template_file.definition.rendered
  family                = local.datadog_name
  network_mode          = "bridge"

  volume {
    name      = "datadog_logs"
    host_path = "/tmp/datadog-logs"
  }

  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "proc"
    host_path = "/proc/"
  }

  volume {
    name      = "cgroup"
    host_path = "/cgroup/"
  }

  volume {
    name      = "log_pointer"
    host_path = local.datadog_log_pointer_dir
  }

  volume {
    name      = "passwd"
    host_path = "/etc/passwd"
  }

  requires_compatibilities = [
    "EC2",
  ]
}

resource "aws_ecs_service" "agent_service" {
  count           = local.datadog_enable
  name            = local.datadog_name
  tags            = merge(local.tags, {type = "operations"})
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.agent_definition[0].arn
  desired_count   = var.max_size

  placement_constraints {
    type = "distinctInstance"
  }
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
