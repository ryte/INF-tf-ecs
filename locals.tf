locals {
  name = "${var.environment}-ecs"

  tags = merge(
    var.tags,
    {
      "Module" = "ecs"
      "Name"   = local.name
    },
  )

  asg_tags = [ for k, v in local.tags:
  {
    key                 = k
    value               = v
    propagate_at_launch = true
  }
  ]
}

locals {
  ecs_engine_auth_type = length(var.ecs_engine_auth_type) > 0 ? "ECS_ENGINE_AUTH_TYPE=${var.ecs_engine_auth_type}" : ""
  ecs_engine_auth_data_dockercfg = length(keys(var.docker_registry_config)) > 0 ? "ECS_ENGINE_AUTH_DATA={${replace(
    join(",", data.template_file.dockercfg_registry_config.*.rendered),
    "\n",
    "",
  )}}" : ""
  ecs_engine_auth_data_docker = length(keys(var.docker_registry_config)) > 0 ? "ECS_ENGINE_AUTH_DATA={${replace(
    join(",", data.template_file.docker_registry_config.*.rendered),
    "\n",
    "",
  )}}" : ""
}
