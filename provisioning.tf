data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.cloudinit.rendered
  }
}

// generate dockercfg Authentication Format based Docker registry configuration
// see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
data "template_file" "dockercfg_registry_config" {
  count    = length(keys(var.docker_registry_config))
  template = file("${path.module}/docker-registry/dockercfg.tpl")

  vars = {
    repo = element(keys(var.docker_registry_config), count.index)
    auth = element(
      split(
        ",",
        var.docker_registry_config[element(keys(var.docker_registry_config), count.index)],
      ),
      0,
    )
    email = element(
      split(
        ",",
        var.docker_registry_config[element(keys(var.docker_registry_config), count.index)],
      ),
      1,
    )
  }
}

// generate docker Authentication Format based Docker registry configuration
// see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
data "template_file" "docker_registry_config" {
  count    = length(keys(var.docker_registry_config))
  template = file("${path.module}/docker-registry/docker.tpl")

  vars = {
    repo = element(keys(var.docker_registry_config), count.index)
    username = element(
      split(
        ",",
        var.docker_registry_config[element(keys(var.docker_registry_config), count.index)],
      ),
      0,
    )
    password = element(
      split(
        ",",
        var.docker_registry_config[element(keys(var.docker_registry_config), count.index)],
      ),
      1,
    )
    email = element(
      split(
        ",",
        var.docker_registry_config[element(keys(var.docker_registry_config), count.index)],
      ),
      2,
    )
  }
}

data "template_file" "cloudinit" {
  template = file("${path.module}/userdata/cloudinit.sh")

  vars = {
    cluster_name            = local.name
    ecs_engine_auth_type    = local.ecs_engine_auth_type
    list_of_registries      = var.ecs_engine_auth_type == "dockercfg" ? local.ecs_engine_auth_data_dockercfg : local.ecs_engine_auth_data_docker
    datadog_enable          = local.datadog_enable
    datadog_log_pointer_dir = local.datadog_log_pointer_dir
  }
}

data "template_file" "setup" {
  template = file("${path.module}/userdata/setup.sh")

  vars = {
    cluster_name = local.name
    aws_region   = data.aws_region.current.id
  }
}

resource "aws_ssm_association" "setup" {
  lifecycle {
    ignore_changes = [association_name]
  }

  association_name = "${local.name}-setup"
  name             = "AWS-RunShellScript"

  parameters = {
    commands = data.template_file.setup.rendered
  }

  targets {
    key    = "tag:Name"
    values = [local.name]
  }
}
