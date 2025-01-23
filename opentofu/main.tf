variable "asg_name" {
  description = "The name of the Auto Scaling Group"
  type        = string
}

data "aws_instances" "production" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [var.asg_name]
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_usage_alarm" {
  alarm_name                = "Production Memory Use > 80%"
  actions_enabled           = true
  alarm_actions             = ["arn:aws:sns:eu-west-2:110304303563:notifications"]
  ok_actions                = []
  insufficient_data_actions = []

  metric_name   = "mem_used_percent"
  namespace     = "System/Linux"
  statistic     = "Average"

  dimensions = {
    InstanceId = data.aws_instances.production.ids[0]
    AutoScalingGroupName = var.asg_name
  }

  period              = 900
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "filesystem_free_space_alarm" {
  alarm_name                = "Production file system < 5 GB free"
  actions_enabled           = true
  alarm_actions             = ["arn:aws:sns:eu-west-2:110304303563:notifications"]
  ok_actions                = []
  insufficient_data_actions = []

  metric_name   = "disk_free"
  namespace     = "System/Linux"
  statistic     = "Minimum"

  dimensions = {
    path                = "/"
    InstanceId          = data.aws_instances.production.ids[0]
    AutoScalingGroupName = var.asg_name
    device              = "nvme0n1p1"
    fstype              = "xfs"
  }

  period              = 900
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 5
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "missing"
}

