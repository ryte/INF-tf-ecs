locals {
  # even if it might be obvious for most people:
  # do not reword the content of these variables
  datadog_enable          = "${length(var.datadog_api_key) > 0 ? 1 : 0}"
  datadog_name            = "datadog-agent"
  datadog_log_pointer_dir = "/opt/datadog-agent/run/"
}

locals {
  datadog_supervisor = "${local.datadog_name}-supervisor"
}

data "template_file" "definition" {
  template = "${file("${path.module}/datadog/definition.json")}"

  vars {
    datadog_name = "${local.datadog_name}"
    dd_api_key   = "${var.datadog_api_key}"
  }
}

data "template_file" "supervisor" {
  template = "${file("${path.module}/datadog/supervisor.sh")}"

  vars {
    cluster      = "${local.name}"
    datadog_name = "${aws_ecs_task_definition.agent_definition.family}"
    region       = "${data.aws_region.current.id}"
  }
}

data "template_file" "supervisor_cron" {
  template = "${file("${path.module}/datadog/supervisor.cron")}"

  vars {
    datadog_name = "${local.datadog_supervisor}"
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
    actions= [
      "ecs:RegisterContainerInstance",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Submit*",
      "ecs:Poll",
      "ecs:StartTask",
      "ecs:StartTelemetrySession"
    ],
    resources = ["*"]
  }
}

resource "aws_iam_policy" "agent_policy" {
  name   = "${local.datadog_name}-policy"
  policy = "${data.aws_iam_policy_document.agent_policy.json}"
}

resource "aws_iam_role" "agent_role" {
  name               = "${local.datadog_name}-ecs"
  assume_role_policy = "${data.aws_iam_policy_document.agent_trust_policy.json}"
}

resource "aws_iam_instance_profile" "agent_profile" {
  name = "${local.datadog_name}"
  role = "${aws_iam_role.agent_role.name}"
}

resource "aws_iam_role_policy_attachment" "agent_role_default" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = "${aws_iam_role.agent_role.name}"
}

resource "aws_iam_role_policy_attachment" "agent_role_attachment" {
  policy_arn = "${aws_iam_policy.agent_policy.arn}"
  role       = "${aws_iam_role.agent_role.name}"
}

resource "aws_ecs_task_definition" "agent_definition" {
  depends_on = [
    "aws_iam_role.agent_role",
  ]

  container_definitions = "${data.template_file.definition.rendered}"
  family                = "${local.datadog_name}"
  network_mode          = "bridge"

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
    host_path = "${local.datadog_log_pointer_dir}"
  }

  requires_compatibilities = [
    "EC2",
  ]
}
