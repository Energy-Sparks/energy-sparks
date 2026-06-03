data "aws_db_instances" "all" {}

locals {
  test_db = [for id in data.aws_db_instances.all.instance_identifiers : id if can(regex("energy-sparks-test.*", id))][0]
}

resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "Main"
  dashboard_body = jsonencode({
    "widgets" : [
      {
        "height" : 10,
        "width" : 10,
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "properties" : {
          "annotations" : {
            "horizontal" : [
              {
                "color" : "#d62728",
                "label" : "80% usage",
                "value" : 80
              }
            ]
          },
          "metrics" : [
            ["System/Linux", "mem_used_percent", "InstanceId", data.aws_instances.production.ids[0], "AutoScalingGroupName", var.prod_asg_name, { "color" : "#d62728" }],
            ["...", data.aws_instances.test.ids[0], ".", var.test_asg_name, { "color" : "#1f77b4" }]
          ],
          "period" : 60,
          "region" : "eu-west-2",
          "stacked" : false,
          "stat" : "Maximum",
          "title" : "Memory",
          "view" : "timeSeries",
          "yAxis" : {
            "left" : {
              "max" : 100,
              "min" : 0
            }
          }
        }
      },
      {
        "height" : 10,
        "width" : 10,
        "type" : "metric",
        "x" : 10,
        "y" : 0,
        "properties" : {
          "annotations" : {
            "horizontal" : [
              {
                "color" : "#d62728",
                "label" : "80% usage",
                "value" : 80
              }
            ]
          },
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.test_asg_name, { "color" : "#1f77b4", "label" : "test ASG" }],
            ["...", var.prod_asg_name, { "color" : "#d62728", "label" : "prod ASG" }]
          ],
          "period" : 60,
          "region" : "eu-west-2",
          "stacked" : false,
          "stat" : "Maximum",
          "title" : "CPU",
          "view" : "timeSeries",
          "yAxis" : {
            "left" : {
              "max" : 100,
              "min" : 0
            }
          }
        }
      },
      # these next 2 not working on test - think because extended monitoring not enabled
      {
        "height" : 10,
        "width" : 10,
        "type" : "metric",
        "x" : 0,
        "y" : 10,
        "properties" : {
          "metrics" : [
            [{ "color" : "#1f77b4", "expression" : "100*(m5/4294967296)", "id" : "e2", "label" : "test", "region" : "eu-west-2" }],
            [{ "color" : "#d62728", "expression" : "100*(m4/17179869184)", "id" : "e3", "label" : "prod", "region" : "eu-west-2" }],
            ["System/Linux", "procstat_memory_rss", "pidfile", "/var/pids/worker.pid", "InstanceId", data.aws_instances.production.ids[0], "process_name", "bundle", "AutoScalingGroupName", var.prod_asg_name, { "id" : "m4", "region" : "eu-west-2", "visible" : false }],
            ["...", data.aws_instances.test.ids[0], ".", ".", ".", var.test_asg_name, { "id" : "m5", "region" : "eu-west-2", "visible" : false }]
          ],
          "period" : 300,
          "region" : "eu-west-2",
          "stacked" : false,
          "stat" : "Average",
          "title" : "Good Job Memory (procstat_memory_rss / total mem)",
          "view" : "timeSeries",
          "yAxis" : {
            "left" : {
              "label" : "%",
              "max" : 100,
              "min" : 0,
              "showUnits" : true
            },
            "right" : {
              "showUnits" : false
            }
          }
        }
      },
      {
        "height" : 10,
        "width" : 10,
        "type" : "metric",
        "x" : 10,
        "y" : 10,
        "properties" : {
          "metrics" : [
            ["System/Linux", "procstat_cpu_usage", "pidfile", "/var/pids/worker.pid", "InstanceId", data.aws_instances.production.ids[0], "process_name", "bundle", "AutoScalingGroupName", var.prod_asg_name, { "color" : "#d62728" }],
            ["...", data.aws_instances.test.ids[0], ".", ".", ".", var.test_asg_name, { "color" : "#1f77b4" }]
          ],
          "period" : 300,
          "region" : "eu-west-2",
          "stacked" : false,
          "stat" : "Average",
          "title" : "Good Job CPU (procstat_cpu_usage)",
          "view" : "timeSeries",
          "yAxis" : {
            "left" : {
              "max" : 100,
              "min" : 0
            }
          }
        }
      },
      {
        "height" : 10,
        "width" : 10,
        "x" : 0,
        "y" : 20,
        "type" : "metric",
        "properties" : {
          "metrics": [
            [ "GoodJob", "queued", "InstanceId", data.aws_instances.production.ids[0], "QueueName", "default", { "region": "eu-west-2", "color": "#d62728" } ],
            [ "...", data.aws_instances.test.ids[0], ".", ".", { "region": "eu-west-2", "color": "#1f77b4" } ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "eu-west-2",
          "period": 300,
          "stat": "Average",
          "start": "-PT72H",
          "end": "P0D",
          "title": "Good Job Default Queue Size"
        }
      },
      {
        "height" : 10,
        "width" : 10,
        "x" : 10,
        "y" : 20,
        "type" : "metric",
        "properties" : {
          "metrics": [
            [ "GoodJob", "running", "InstanceId", data.aws_instances.production.ids[0], "QueueName", "default", { "region": "eu-west-2", "color": "#d62728" } ],
            [ "...", data.aws_instances.test.ids[0], ".", ".", { "region": "eu-west-2", "color": "#1f77b4" } ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "eu-west-2",
          "period": 300,
          "stat": "Average",
          "start": "-PT72H",
          "end": "P0D",
          "title": "Good Job Default Queue Running"
        }
      },
      {
        "height" : 10,
        "width" : 10,
        "x" : 0,
        "y" : 30,
        "type" : "metric",
        "properties" : {
          "metrics": [
            [ "GoodJob", "queued", "InstanceId", data.aws_instances.production.ids[0], "QueueName", "regeneration", { "region": "eu-west-2", "color": "#d62728" } ],
            [ "...", data.aws_instances.test.ids[0], ".", ".", { "region": "eu-west-2", "color": "#1f77b4" } ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "eu-west-2",
          "period": 300,
          "stat": "Average",
          "start": "-PT72H",
          "end": "P0D",
          "title": "Good Job Regeneration Queue Size"
        }
      },
      {
        "height" : 10,
        "width" : 10,
        "x" : 10,
        "y" : 30,
        "type" : "metric",
        "properties" : {
          "metrics": [
            [ "GoodJob", "running", "InstanceId", data.aws_instances.production.ids[0], "QueueName", "regeneration", { "region": "eu-west-2", "color": "#d62728" } ],
            [ "...", data.aws_instances.test.ids[0], ".", ".", { "region": "eu-west-2", "color": "#1f77b4" } ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "eu-west-2",
          "period": 300,
          "stat": "Average",
          "start": "-PT72H",
          "end": "P0D",
          "title": "Good Job Regeneration Queue Running"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 40,
        "width" : 10,
        "height" : 10,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "energy-sparks-production-db-2022", { "color" : "#d62728" }],
            ["...", local.test_db, { "color" : "#1f77b4" }]
          ],
          "region" : "eu-west-2",
          "yAxis" : {
            "left" : {
              "min" : 0
            }
          },
          "title" : "Database FreeStorageSpace",
          "period" : 300,
          "stat" : "Maximum",
        }
      },
      {
        "height" : 10,
        "width" : 10,
        "x" : 10,
        "y" : 40,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["System/Linux", "disk_free", "path", "/", "InstanceId", data.aws_instances.production.ids[0], "AutoScalingGroupName", var.prod_asg_name, "device", "nvme0n1p1", "fstype", "xfs", { "color" : "#d62728" }],
            ["...", data.aws_instances.test.ids[0], ".", var.test_asg_name, ".", ".", ".", ".", { "color" : "#1f77b4" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "eu-west-2",
          "title" : "Server disk space available",
          "period" : 300,
          "stat" : "Average",
          "yAxis" : {
            "left" : {
              "min" : 0
            }
          }
        }
      }
    ]
  })
}
