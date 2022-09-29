class ApplicationJob < ActiveJob::Base
  after_perform :send_metrics_to_cloudwatch

  def send_metrics_to_cloudwatch
    send_memory_usage_of_the_delayed_job_processes_to_cloudwatch
    send_counts_of_delayed_job_work_processes_to_cloudwatch
  end

  private

  def send_memory_usage_of_the_delayed_job_processes_to_cloudwatch
    Aws::Metrics.new(
      namespace: 'delayed-job',
      metric_name: 'DelayedJobMemoryUsage',
      value: delayed_job_memory_usage,
      aws_unit_string: 'Kilobytes'
    ).send_to_cloudwatch
  end

  def send_counts_of_delayed_job_work_processes_to_cloudwatch
    Aws::Metrics.new(
      namespace: 'delayed-job',
      metric_name: 'DelayedJobWorkerProcesses',
      value: pids.size,
      aws_unit_string: 'Count'
    ).send_to_cloudwatch
  end

  def pids
    `pgrep -f jobs:work`.split
  end

  def delayed_job_memory_usage
    pids.split.map { |pid| `ps -o rss= -p #{pid}`.to_i }.sum # Total in Kilobytes
  end
end
