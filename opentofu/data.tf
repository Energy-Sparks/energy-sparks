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
