module Aws
  class Metrics
    VALID_UNITS = [
      'Seconds', 'Microseconds', 'Milliseconds',
      'Bytes', 'Kilobytes', 'Megabytes', 'Gigabytes', 'Terabytes',
      'Bits', 'Kilobits', 'Megabits', 'Gigabits', 'Terabits',
      'Percent', 'Count',
      'Bytes/Second', 'Kilobytes/Second', 'Megabytes/Second', 'Gigabytes/Second', 'Terabytes/Second',
      'Bits/Second', 'Kilobits/Second', 'Megabits/Second', 'Gigabits/Second', 'Terabits/Second',
      'Count/Second',
      'None'
    ].freeze

    def initialize(namespace:, metric_name:, value:, aws_unit_string:)
      raise 'Invalid CloudWatch Unit' unless VALID_UNITS.include?(aws_unit_string)

      @namespace = namespace
      @metric_name = metric_name
      @value = value
      @aws_unit_string = aws_unit_string
    end

    def send_to_cloudwatch
      cloudwatch_client.put_metric_data(
        namespace: @namespace,
        metric_data: aws_metrics_payload
      )
    end

    private

    def aws_metrics_payload
      {
        metric_name: @metric_name,
        dimensions: [
          {
            name: 'hostname',
            value: Socket.gethostname
          }
        ],
        timestamp: Time.now.utc,
        value: @value,
        unit: @aws_unit_string
      }
    end

    def cloudwatch_client
      Aws::CloudWatch::Client.new(region: 'eu-west-2')
    end
  end
end
