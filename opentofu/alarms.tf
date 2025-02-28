resource "aws_cloudwatch_metric_alarm" "memory_usage_alarm" {
  alarm_name                = "Production Memory Use > 80%"
  actions_enabled           = true
  alarm_actions             = ["arn:aws:sns:eu-west-2:110304303563:notifications"]
  ok_actions                = []
  insufficient_data_actions = []

  metric_name = "mem_used_percent"
  namespace   = "System/Linux"
  statistic   = "Average"

  dimensions = {
    InstanceId           = data.aws_instances.production.ids[0]
    AutoScalingGroupName = var.prod_asg_name
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

  metric_name = "disk_free"
  namespace   = "System/Linux"
  statistic   = "Minimum"

  dimensions = {
    path                 = "/"
    InstanceId           = data.aws_instances.production.ids[0]
    AutoScalingGroupName = var.prod_asg_name
    device               = "nvme0n1p1"
    fstype               = "xfs"
  }

  period              = 900
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 5000000000
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name                = "Production Server Above 80% CPU"
  actions_enabled           = true
  alarm_actions             = ["arn:aws:sns:eu-west-2:110304303563:notifications"]
  ok_actions                = []
  insufficient_data_actions = []

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"
  statistic   = "Average"

  dimensions = {
    AutoScalingGroupName = var.prod_asg_name
  }

  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "postgres_free_space_alert" {
  alarm_name                = "Any Postgres DB Warning < 4 GB"
  actions_enabled           = true
  alarm_actions             = ["arn:aws:sns:eu-west-2:110304303563:notifications"]
  ok_actions                = []
  insufficient_data_actions = []

  metric_name = "FreeStorageSpace"
  namespace   = "AWS/RDS"
  statistic   = "Minimum"

  dimensions = {
    EngineName = "postgres"
  }

  period              = 900
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 4000000000
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "production_postgres_free_space_alert" {
  alarm_name                = "Production DB Warning < 10 GB"
  actions_enabled           = true
  alarm_actions             = ["arn:aws:sns:eu-west-2:110304303563:notifications"]
  ok_actions                = []
  insufficient_data_actions = []

  metric_name = "FreeStorageSpace"
  namespace   = "AWS/RDS"
  statistic   = "Minimum"

  dimensions = {
    DBInstanceIdentifier = "energy-sparks-production-db-2022"
  }

  period              = 900
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 10000000000
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "missing"
}
