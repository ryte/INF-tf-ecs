data "aws_iam_policy_document" "trust_policy_container_instance" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "policy_container_instance" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTask",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_instance_profile" "profile" {
  role = aws_iam_role.role_container_instance.name
}

resource "aws_iam_policy" "policy_container_instance" {
  name   = "${local.name}-container_instance"
  policy = data.aws_iam_policy_document.policy_container_instance.json
}

resource "aws_iam_role" "role_container_instance" {
  assume_role_policy = data.aws_iam_policy_document.trust_policy_container_instance.json
  name               = "${local.name}-container_instance"
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.role_container_instance.name
}

resource "aws_iam_role_policy_attachment" "policy_container_instance" {
  policy_arn = aws_iam_policy.policy_container_instance.arn
  role       = aws_iam_role.role_container_instance.name
}

# resource "aws_iam_role_policy_attachment" "ci" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
#   role       = "${aws_iam_role.role_container_instance.name}"
# }
#
# resource "aws_iam_role_policy_attachment" "ss" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
#   role       = "${aws_iam_role.role_container_instance.name}"
# }
