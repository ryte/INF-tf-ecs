# INF-tf-ecs

Terraform module for setting up a ECS Cluster


NOTE: currently it's only possible to deploy the cluster on EC2 instances, which are created and provisioned by this module

NOTE: the EC2 deployment works with a autoscaling group, so some changes are not applied to the machines until they are recreated by the ASG

This project is [internal open source](https://en.wikipedia.org/wiki/Inner_source)
and currently maintained by the [INF](https://github.com/orgs/ryte/teams/inf).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- terraform (>= 0.12)

## Providers

The following providers are used by this module:

- aws

- template

## Required Inputs

The following input variables are required:

### ami\_id

Description: 'the ami id to use for the instances'

Type: `string`

### desired\_capacity

Description: the ASG desired\_capacity of the EC2 machines (number of hosts which should be running)

Type: `string`

### environment

Description: the environment this cluster is running in (e.g. 'testing')

Type: `string`

### max\_size

Description: the ASG max\_size of the EC2 machines

Type: `string`

### min\_size

Description: the ASG min\_size of the EC2 machines

Type: `string`

### squad

Description: the owner of this cluster

Type: `string`

### subnet\_ids\_cluster

Description: a list of subnet ids in which the ASG deploys to

Type: `list(string)`

### vpc\_id

Description: the VPC the ASG should be deployed in

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### alb\_instance\_sgs

Description: SGs which are beeing added to the instances (DEPRECATED, use allow\_to\_sgs from now on)

Type: `list(string)`

Default: `[]`

### allow\_to\_sgs

Description:   a new rule is beeing added to the provided list of security groups which allows the EC2 instances access to a specififed port, e.G. : `["${var.sg_name},6379"]`

Type: `list(string)`

Default: `[]`

### availability\_zones

Description: unused (DEPRECATED)

Type: `list`

Default:

```json
[
  "a",
  "b",
  "c"
]
```

### datadog\_api\_key

Description: if the datadog\_api\_key variable is set a single datadog agent task definition is deployed on every EC2 machine for metrics and log gathering

Type: `string`

Default: `""`

### docker\_registry\_config

Description:     Set Docker registry authentication information used by ECS. In dependendcy of `ecs_engine_auth_type` set this map like:  
    1. for dockercfg:
      "repository" = "auth,email"  
    1. for docker
      "repository" = "username,password,email"  
    1. for jfrog
      "repository" = "token,username"

    see: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html

Type: `map(string)`

Default: `{}`

### ecs\_engine\_auth\_type

Description:     Set Docker registry authentication type information used by ECS. Valid values are:
      - dockercfg
      - docker
      - jfrog

    See:  
      https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html

Type: `string`

Default: `""`

### health\_check\_type

Description: the ASG health\_check\_type of the EC2 machines

Type: `string`

Default: `"ELB"`

### instance\_ssh\_cidr\_blocks

Description: a list of CIDR blocks which are allowed ssh access, since it's internal no restriction is needed

Type: `list(string)`

Default:

```json
[
  "0.0.0.0/0"
]
```

### instance\_tags

Description: Tags to be added to each EC2 instances part of the cluster.  
This must be a list like this
 [{  
    key                 = "InstallCW"  
    value               = "true"  
    propagate\_at\_launch = true
  },
  {  
    key                 = "test"  
    value               = "Test2"  
    propagate\_at\_launch = true
  }]

Type:

```hcl
list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
```

Default: `[]`

### instance\_type

Description: the EC2 instance type which shuld be spawend

Type: `string`

Default: `"t2.small"`

### instance\_volume\_size

Description: the instance volume size

Type: `string`

Default: `"64"`

### instance\_volume\_type

Description: the instance volume type

Type: `string`

Default: `"gp2"`

### root\_volume\_size

Description: the instance root device volume size

Type: `string`

Default: `"20"`

### root\_volume\_type

Description: the instance root device volume type

Type: `string`

Default: `"gp2"`

### ssh\_key\_name

Description: the ssh\_key\_name which is used as the EC2 Key Name

Type: `string`

Default: `""`

### tags

Description: common tags to add to the ressources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### ecs\_cluster\_id

Description: id of the cluster

### ecs\_cluster\_name

Description: name of the cluster

### ecs\_cluster\_sg

Description: security group of the cluster

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

```hcl
module "ecs" {
  source      = "github.com/ryte/INF-tf-ecs?ref=v0.2.4"
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

## Authors

- [Armin Grodon](https://github.com/x4121)
- [Markus Schmid](https://github.com/h0raz)

## Changelog

- 0.2.4 - Removed deprecated `null_data_source`
- 0.2.3 - Add variable `environment` and `squad` instead of reading from tags
- 0.2.2 - Datadog enriched live containers view with process list
- 0.2.1 - Remove redis-cli from ECS hosts
- 0.2.0 - Upgrade to terraform 0.12.x
- 0.1.5 - Remove redis-cli from ECS hosts (backport)
- 0.1.4 - Extend root block device
- 0.1.3 - Fix Datadog-agent writing inside container
- 0.1.2 - Enable Dogstatsd non\_local\_traffic
- 0.1.1 - Datadog-agent enabled Dogstatsd
- 0.1.0 - Initial release.

## License

This software is released under the MIT License (see `LICENSE`).
