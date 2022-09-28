class ApplicationJob < ActiveJob::Base
  after_perform :send_metrics_to_cloudwatch

  def send_metrics_to_cloudwatch
    Aws::Metrics.new(namespace: '', aws_metrics: aws_metrics).send_to_cloudwatch
  end

  private

  def aws_metrics
    {
      metric_name: '',
      dimensions: [
        {
          name: 'hostname',
          value: ''
        }
      ],
      timestamp: DateTime.now,
      value: '',
      unit: ''
    }
  end
end
