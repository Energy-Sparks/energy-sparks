class ApplicationJob < ActiveJob::Base
  after_perform :send_metrics_to_cloudwatch

  def send_metrics_to_cloudwatch
    Aws::Metrics.new(namespace: '', aws_metrics: '').send_to_cloudwatch
  end
end
