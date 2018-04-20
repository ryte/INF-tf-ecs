data "aws_region" "current" {}

resource "aws_ecs_cluster" "cluster" {
  depends_on = [
    "aws_cloudwatch_log_group.log_group",
  ]

  name = "${local.name}"
}

resource "aws_autoscaling_group" "asg" {
  lifecycle {
    create_before_destroy = true
  }

  desired_capacity = "${var.desired_capacity}"

  health_check_type = "${var.health_check_type}"

  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  health_check_type    = "ELB"
  launch_configuration = "${aws_launch_configuration.lc.name}"
  min_elb_capacity     = 0
  name                 = "${local.name}-asg"
  tags                 = "${concat(local.asg_tags, var.instance_tags)}"
  vpc_zone_identifier  = ["${var.subnet_ids_cluster}"]
}

resource "aws_launch_configuration" "lc" {
  lifecycle {
    create_before_destroy = true
  }

  ebs_block_device {
    device_name = "/dev/xvdcz"
    encrypted   = true
    volume_size = "${var.instance_volume_size}"
    volume_type = "${var.instance_volume_type}"
  }

  name_prefix          = "${local.name}-lc"
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"
  image_id             = "${var.ami_id}"
  instance_type        = "${var.instance_type}"
  user_data            = "${data.template_cloudinit_config.config.rendered}"
  key_name             = "${var.ssh_key_name}"

  // combine alb_instance_sgs defined SGs and the default ECS instance SG for SSH access
  security_groups = ["${concat(list(aws_security_group.instance_default_sg.id), var.alb_instance_sgs)}"]
}
