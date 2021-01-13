# INF-tf-ecs

Terraform module for setting up a ECS Cluster


NOTE: currently it's only possible to deploy the cluster on EC2 instances, which are created and provisioned by this module

NOTE: the EC2 deployment works with a autoscaling group, so some changes are not applied to the machines until they are recreated by the ASG

This project is [internal open source](https://en.wikipedia.org/wiki/Inner_source)
and currently maintained by the [INF](https://github.com/orgs/ryte/teams/inf).

## Module Input Variables

- `alb_instance_sgs`
    -  __description__: SGs which are beeing added to the instances (DEPRECATED, use allow_to_sgs from now on)
    -  __type__: `list`
    -  __default__: []

- `allow_to_sgs`
    -  __description__: a new rule is beeing added to the provided list of security groups which allows the EC2 instances access to a specififed port, e.G. : `["${var.sg_name},6379"]`
    -  __type__: `list`
    -  __default__: []

- `ami_id`
    -  __description__: 'the ami id to use for the instances'
    -  __type__: `string`

- `availability_zones`
    -  __description__: not beeing used, will be removed with the next version
    -  __type__: `string`
    -  __default__: ["a", "b", "c"]

- `datadog_api_key`
    -  __description__: if the datadog_api_key variable is set a single datadog agent task definition is deployed on every EC2 machine for metrics and log gathering
    -  __type__: `string`
    -  __default__: ""

- `desired_capacity`
    -  __description__: the ASG desired_capacity of the EC2 machines (number of hosts which should be running)
    -  __type__: `string`

- `environment`
    -  __description__: the environment this cluster is running in (e.g. 'testing')
    -  __type__: `string`

- `health_check_type`
    -  __description__: the ASG health_check_type of the EC2 machines
    -  __type__: `string`
    -  __default__: "ELB"

- `docker_registry_config`
    -  __description__: Set Docker registry authentication information used by ECS. In dependendcy of `ecs_engine_auth_type` set this map like:
    1. for dockercfg:
      "repository" = "auth,email"
    1. for docker
      "repository" = "username,password,email"
    1. for jfrog
      "repository" = "token,username"

    see: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html

    -  __type__: `map`
    -  __default__: {}

- `ecs_engine_auth_type`
    -  __description__: Set Docker registry authentication type information used by ECS. Valid values are:
        - "dockercfg"
        - "docker"

    See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html

    -  __type__: `string`
    -  __default__: ""

- `instance_ssh_cidr_blocks`
    -  __description__: a list of CIDR blocks which are allowed ssh access, since it's internal no restriction is needed
    -  __type__: `list`
    -  __default__: ["0.0.0.0/0"]

- `instance_tags`
    -  __description__: Tags to be added only to EC2 instances part of the cluster, used for SSH key deployment
    ```
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
    ```

    -  __type__: `list`
    -  __default__: []

- `instance_type`
    -  __description__: the EC2 instance type which shuld be spawend
    -  __type__: `string`
    -  __default__: "t2.small"

- `instance_volume_size`
    -  __description__: the instance volume size
    -  __type__: `string`
    -  __default__: "64"

- `instance_volume_type`
    -  __description__: the instance volume type
    -  __type__: `string`
    -  __default__: "gp2"

- `max_size`
    -  __description__: the ASG max_size of the EC2 machines
    -  __type__: `string`

- `min_size`
    -  __description__: the ASG min_size of the EC2 machines
    -  __type__: `string`

- `squad`
    -  __description__: the owner of this cluster
    -  __type__: `string`

- `ssh_key_name`
    -  __description__: the ssh_key_name which is used as the EC2 Key Name
    -  __type__: `string`
    -  __default__: ""

- `subnet_ids_cluster`
    -  __description__: a list of subnet ids in which the ASG deploys to
    -  __type__: `list`

- `tags`
    -  __description__: a map of tags which is added to all supporting ressources
    -  __type__: `map`
    -  __default__: {}

- `root_volume_size`
    -  __description__: the instance root device volume size
    -  __type__: `string`
    -  __default__: "20"

- `root_volume_type`
    -  __description__: the instance root device volume type
    -  __type__: `string`
    -  __default__: "gp2"

- `vpc_id`
    -  __description__: the VPC the ASG should be deployed in
    -  __type__: `string`





## Usage

```hcl
module "ecs" {
  source      = "github.com/ryte/INF-tf-ecs?ref=v0.2.1"
  tags        = local.common_tags
  environment = var.environment
  squad       = var.squad

  ami_id = data.terraform_remote_state.ami.ecs_optimized

  subnet_ids_cluster = data.terraform_remote_state.vpc.subnet_private

  instance_type    = "t2.medium"
  desired_capacity = 3
  max_size         = 5
  min_size         = 1
  root_volume_size = 20
  instance_ssh_cidr_blocks = var.instance_ssh_cidr_blocks

  allow_to_sgs = [
    "${data.terraform_remote_state.cache.authentication_redis_sg},6379"
  ]

  ssh_key_name = var.ssh_key_name

  // set tag for SSH key deployment via SSM
  instance_tags = [{
    key                 = "SSM-sshkeys-ecs"
    value               = "true"
    propagate_at_launch = true
  }]

  ecs_engine_auth_type = "dockercfg"

  docker_registry_config = {
    "ryte-docker.jfrog.io" = "<token>,<user>"
  }

  datadog_api_key = var.datadog_api_key

  vpc_id = data.terraform_remote_state.vpc.vpc_id
}
```


## Outputs

- `ecs_cluster_id`
    -  __description__: id of the cluster
    -  __type__: `string`

- `ecs_cluster_name`
    -  __description__: name of the cluster
    -  __type__: `string`

- `ecs_cluster_sg`
    -  __description__: security group of the cluster
    -  __type__: `string`

## Authors

- [Armin Grodon](https://github.com/x4121)
- [Markus Schmid](https://github.com/h0raz)

## Changelog

- 0.2.3 - Add variable `environment` and `squad` instead of reading from tags
- 0.2.2 - Datadog enriched live containers view with process list
- 0.2.1 - Remove redis-cli from ECS hosts
- 0.2.0 - Upgrade to terraform 0.12.x
- 0.1.5 - Remove redis-cli from ECS hosts (backport)
- 0.1.4 - Extend root block device
- 0.1.3 - Fix Datadog-agent writing inside container
- 0.1.2 - Enable Dogstatsd non_local_traffic
- 0.1.1 - Datadog-agent enabled Dogstatsd
- 0.1.0 - Initial release.

## License

This software is released under the MIT License (see `LICENSE`).
