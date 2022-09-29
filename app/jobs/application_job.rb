class ApplicationJob < ActiveJob::Base
  after_perform :send_metrics_to_cloudwatch

  def send_metrics_to_cloudwatch
    Aws::Metrics.new(namespace: 'delayed-job', aws_metrics: counts_of_delayed_job_work_processes).send_to_cloudwatch
    Aws::Metrics.new(namespace: 'delayed-job', aws_metrics: memory_usage_of_the_delayed_job_processes).send_to_cloudwatch
  end

  private

  def pids
    `pgrep -f jobs:work`.split
  end

  def delayed_job_memory_usage
    pids.split.map { |pid| `ps -o rss= -p #{pid}`.to_i }.sum # Total in Kilobytes
  end

  def memory_usage_of_the_delayed_job_processes
    build_aws_metrics_for(metric_name: 'DelayedJobMemoryUsage', value: delayed_job_memory_usage, aws_unit_string: 'Kilobytes')
  end

  def counts_of_delayed_job_work_processes
    build_aws_metrics_for(metric_name: 'DelayedJobWorkerProcesses', value: pids.size, aws_unit_string: 'Count')
  end

  def build_aws_metrics_for(metric_name:, value:, aws_unit_string:)
    {
      metric_name: metric_name,
      dimensions: [
        {
          name: 'hostname',
          value: Socket.gethostname
        }
      ],
      timestamp: Time.now.utc,
      value: value,
      unit: aws_unit_string
    }
  end
end
