locals {
  name   = "${var.environment}-${var.project}-ecs"
  module = "ecs"
}

locals {
  tags = {
    CID         = "${var.cid}"
    Environment = "${var.environment}"
    Module      = "${local.module}"
    Name        = "${local.name}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
  }

  asg_tags = [
    {
      key                 = "CID"
      value               = "${var.cid}"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Module"
      value               = "${local.module}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${local.name}"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "${var.project}"
      propagate_at_launch = true
    },
  ]
}

locals {
  ecs_engine_auth_type           = "${ length(var.ecs_engine_auth_type) > 0 ? "ECS_ENGINE_AUTH_TYPE=${var.ecs_engine_auth_type}" : "" }"
  ecs_engine_auth_data_dockercfg = "${ length(keys(var.docker_registry_config)) > 0 ? "ECS_ENGINE_AUTH_DATA={${replace( join(",", data.template_file.dockercfg_registry_config.*.rendered), "\n", "" )}}" : "" }"
  ecs_engine_auth_data_docker    = "${ length(keys(var.docker_registry_config)) > 0 ? "ECS_ENGINE_AUTH_DATA={${replace( join(",", data.template_file.docker_registry_config.*.rendered), "\n", "" )}}" : "" }"
}
