module Aws
  class Metrics
    def initialize(namespace:, aws_metrics:)
      @namespace = namespace
      @aws_metrics = aws_metrics
    end

    def send_to_cloudwatch
      cloudwatch_client.put_metric_data(
        namespace: @namespace,
        metric_data: @aws_metrics
      )
    end

    private

    def cloudwatch_client
      Aws::CloudWatch::Client.new(region: 'eu-west-2')
    end
  end
end
