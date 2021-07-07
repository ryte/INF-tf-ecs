variable "ami_id" {
  type        = string
  description = "'the ami id to use for the instances'"
}

variable "tags" {
  type        = map(string)
  description = "common tags to add to the ressources"
  default     = {}
}

variable "subnet_ids_cluster" {
  type        = list(string)
  description = "a list of subnet ids in which the ASG deploys to"
}

variable "vpc_id" {
  type        = string
  description = "the VPC the ASG should be deployed in"
}

variable "availability_zones" {
  description = "unused (DEPRECATED)"
  default     = ["a", "b", "c"]
}

variable "alb_instance_sgs" {
  type        = list(string)
  description = "SGs which are beeing added to the instances (DEPRECATED, use allow_to_sgs from now on)"
  default     = []
}

variable "allow_to_sgs" {
  type        = list(string)
  description = <<DOC
  a new rule is beeing added to the provided list of security groups which allows the EC2 instances access to a specififed port, e.G. : `["$${var.sg_name},6379"]`
DOC
  default     = []
}

variable "instance_ssh_cidr_blocks" {
  type        = list(string)
  description = "a list of CIDR blocks which are allowed ssh access, since it's internal no restriction is needed"
  default     = ["0.0.0.0/0"]
}

variable "desired_capacity" {
  type        = string
  description = "the ASG desired_capacity of the EC2 machines (number of hosts which should be running)"
}

variable "health_check_type" {
  type        = string
  description = "the ASG health_check_type of the EC2 machines"
  default     = "ELB"
}

variable "max_size" {
  type        = string
  description = "the ASG max_size of the EC2 machines"
}

variable "min_size" {
  type        = string
  description = "the ASG min_size of the EC2 machines"
}

variable "instance_type" {
  description = "the EC2 instance type which shuld be spawend"
  default     = "t2.small"
}

variable "root_volume_size" {
  description = "the instance root device volume size"
  default     = "20"
}

variable "root_volume_type" {
  description = "the instance root device volume type"
  default     = "gp2"
}

variable "instance_volume_size" {
  description = "the instance volume size"
  default     = "64"
}

variable "instance_volume_type" {
  description = "the instance volume type"
  default     = "gp2"
}

variable "ssh_key_name" {
  description = "the ssh_key_name which is used as the EC2 Key Name"
  default     = ""
}

variable "instance_tags" {
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
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
  default     = []
}

variable "docker_registry_config" {
  type        = map(string)
  description = <<DOC
    Set Docker registry authentication information used by ECS. In dependendcy of `ecs_engine_auth_type` set this map like:
    1. for dockercfg:
      "repository" = "auth,email"
    1. for docker
      "repository" = "username,password,email"
    1. for jfrog
      "repository" = "token,username"

    see: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
DOC
  default     = {}
}

variable "ecs_engine_auth_type" {
  description = <<DOC
    Set Docker registry authentication type information used by ECS. Valid values are:
      - dockercfg
      - docker
      - jfrog

    See:
      https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
DOC
  default     = ""
}

variable "datadog_api_key" {
  description = "if the datadog_api_key variable is set a single datadog agent task definition is deployed on every EC2 machine for metrics and log gathering"
  default     = ""
}

variable "environment" {
  type        = string
  description = "the environment this cluster is running in (e.g. 'testing')"
}

variable "squad" {
  type        = string
  description = "the owner of this cluster"
}
