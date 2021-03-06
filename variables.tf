variable "ami_id" {
}

variable "tags" {
  type        = map(string)
  description = "common tags to add to the ressources"
  default     = {}
}

variable "subnet_ids_cluster" {
  type = list(string)
}

variable "vpc_id" {
}

variable "availability_zones" {
  default = ["a", "b", "c"]
}

variable "alb_instance_sgs" {
  type    = list(string)
  default = []
}

variable "allow_to_sgs" {
  type    = list(string)
  default = []
}

variable "instance_ssh_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "desired_capacity" {
}

variable "health_check_type" {
  type = string
  default = "ELB"
}

variable "max_size" {
}

variable "min_size" {
}

variable "instance_type" {
  default = "t2.small"
}

variable "root_volume_size" {
  default = "20"
}

variable "root_volume_type" {
  default = "gp2"
}

variable "instance_volume_size" {
  default = "64"
}

variable "instance_volume_type" {
  default = "gp2"
}

variable "ssh_key_name" {
  default = ""
}

variable "instance_tags" {
  type    = list(object({
    key = string
    value = string
    propagate_at_launch = bool
    }))
  default = []

  description = <<DOC
Tags to be added to each EC2 instances part of the cluster.
This must be a list like this
 [{
    key                 = "InstallCW"
    value               = "true"
    propagate_at_launch = true
  },
  {
    key                 = "test"
    value               = "Test2"
    propagate_at_launch = true
  }]
DOC

}

variable "docker_registry_config" {
  type    = map(string)
  default = {}

  description = <<EOF
    Set Docker registry authentication information used by ECS. In dependendcy of `ecs_engine_auth_type` set this map like:
    1) for dockercfg:
      "repository" = "auth,email"

    2) for docker
      "repository" = "username,password,email"

    see:
      https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
EOF

}

variable "ecs_engine_auth_type" {
  default = ""

  description = <<EOF
    Set Docker registry authentication type information used by ECS. Valid values are:
      - dockercfg
      - docker

    See:
      https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
EOF

}

variable "datadog_api_key" {
  default = ""
}

variable "environment" {
}

variable "squad" {
}
