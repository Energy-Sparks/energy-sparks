module Aws
  class Metrics
    VALID_UNITS = %w(
      Seconds Microseconds Milliseconds
      Bytes Kilobytes Megabytes Gigabytes Terabytes
      Bits Kilobits Megabits Gigabits Terabits
      Percent Count
      Bytes/Second Kilobytes/Second Megabytes/Second Gigabytes/Second Terabytes/Second Bits/Second Kilobits/Second Megabits/Second Gigabits/Second Terabits/Second Count/Second
      None
    ).freeze

    def initialize(namespace:, metric_name:, value:, aws_unit_string:)
      raise 'Invalid CloudWatch Unit' unless VALID_UNITS.include?(aws_unit_string)

      @namespace = namespace
      @metric_name = metric_name
      @value = value
      @aws_unit_string = aws_unit_string
    end

    def send_to_cloudwatch
      cloudwatch_client.put_metric_data(aws_metrics_payload)
    end

    private

    def aws_metrics_payload
      # see https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/CloudWatch/Client.html#put_metric_data-instance_method
      {
        namespace: @namespace, # required
        metric_data: [ # required
          {
            metric_name: @metric_name, # required
            dimensions: [
              {
                name: 'hostname', # required
                value: Socket.gethostname, # required
              },
            ],
            timestamp: Time.zone.now,
            value: @value,
            # statistic_values: {
            #   sample_count: 1.0, # required
            #   sum: 1.0, # required
            #   minimum: 1.0, # required
            #   maximum: 1.0, # required
            # },
            # values: [1.0],
            # counts: [1.0],
            unit: @aws_unit_string
            # , storage_resolution: 1,
          }
        ],
      }
    end

    def cloudwatch_client
      Aws::CloudWatch::Client.new(
        region: 'eu-west-2',
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
    end
  end
end
