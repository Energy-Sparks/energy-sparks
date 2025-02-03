variable "prod_asg_name" {
  type    = string
  default = "awseb-e-kqmpigtu2t-stack-AWSEBAutoScalingGroup-fOQTNTdwEiv5"
}

variable "test_asg_name" {
  type    = string
  default = "awseb-e-4mavdvpapq-stack-AWSEBAutoScalingGroup-R0KgD0ig7oX8"
}

data "aws_instances" "production" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [var.prod_asg_name]
  }
}

data "aws_instances" "test" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [var.test_asg_name]
  }
}

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
  threshold           = 5
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_dashboard" "cpu_and_memory" {
  dashboard_name = "CPU_and_Memory_tf"
  dashboard_body = jsonencode({
    "widgets" : [
      {
        "height" : 12,
        "width" : 12,
        "y" : 0,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["System/Linux", "mem_used_percent", "InstanceId", data.aws_instances.production.ids[0],
            "AutoScalingGroupName", var.prod_asg_name, { "region" : "eu-west-2", "color" : "#d62728" }],
            ["...", data.aws_instances.test.ids[0], ".", var.test_asg_name,
            { "region" : "eu-west-2", "color" : "#1f77b4" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "eu-west-2",
          "stat" : "Maximum",
          "period" : 60,
          "annotations" : {
            "horizontal" : [
              {
                "color" : "#d62728",
                "label" : "80% usage",
                "value" : 80
              }
            ]
          },
          "title" : "Memory",
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100
            }
          }
        }
      },
      {
        "height" : 12,
        "width" : 11,
        "y" : 0,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.test_asg_name,
            { "color" : "#1f77b4", "label" : "test-4-0-9 ASG", "region" : "eu-west-2" }],
            ["...", var.prod_asg_name, { "label" : "prod-4-0-9 ASG", "color" : "#d62728" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "eu-west-2",
          "stat" : "Maximum",
          "period" : 60,
          "annotations" : {
            "horizontal" : [
              {
                "color" : "#d62728",
                "label" : "80% usage",
                "value" : 80
              }
            ]
          },
          "title" : "CPU",
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100
            }
          }
        }
      },
      {
        "height" : 8,
        "width" : 12,
        "y" : 12,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            [{ "expression" : "100*(m5/4294967296)", "label" : "test-4-0-9", "id" : "e2", "region" : "eu-west-2",
            "color" : "#1f77b4" }],
            [{ "expression" : "100*(m4/17179869184)", "label" : "prod-4-0-9", "id" : "e3", "region" : "eu-west-2",
            "color" : "#d62728" }],
            ["System/Linux", "procstat_memory_rss", "pidfile", "/var/pids/worker.pid",
              "InstanceId", data.aws_instances.production.ids[0], "process_name", "ruby3.2",
              "AutoScalingGroupName", var.prod_asg_name,
            { "id" : "m4", "region" : "eu-west-2", "visible" : false }],
            ["...", data.aws_instances.test.ids[0], ".", ".", ".", var.test_asg_name,
            { "id" : "m5", "region" : "eu-west-2", "visible" : false }],
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "eu-west-2",
          "stat" : "Average",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "showUnits" : true,
              "label" : "%",
              "min" : 0,
              "max" : 100
            },
            "right" : {
              "showUnits" : false
            }
          },
          "title" : "Good Job Memory (procstat_memory_rss / total mem)"
        }
      },
      {
        "height" : 8,
        "width" : 11,
        "y" : 12,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["System/Linux", "procstat_cpu_usage", "pidfile", "/var/pids/worker.pid",
              "InstanceId", data.aws_instances.production.ids[0], "process_name", "ruby3.2",
            "AutoScalingGroupName", var.prod_asg_name],
            ["...", data.aws_instances.test.ids[0], ".", ".", ".", var.test_asg_name, { "color" : "#d62728" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "eu-west-2",
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100
            }
          },
          "stat" : "Average",
          "period" : 300,
          "title" : "Good Job CPU (procstat_cpu_usage)"
        }
      }
    ]
  })
}
