# frozen_string_literal: true

namespace :jobs do
  desc 'Send good job queue metrics to AWS Cloudwatch'
  task send_good_job_queue_metrics_to_cloudwatch: :environment do
    instance_id = `ec2-metadata --instance-id | cut -d " " -f 2`.strip
    command_template = 'aws cloudwatch put-metric-data --metric-name %<metric_name>s --timestamp %<time_stamp>s ' \
                       "--namespace GoodJob --value=%<value>s --unit Count --region='eu-west-2' " \
                       "--dimensions InstanceId=#{instance_id},QueueName=%<queue_name>s"
    GoodJob::Job.distinct(:queue_name).pluck(:queue_name).each do |queue_name|
      # possible statuses: [:scheduled, :retried, :queued, :running, :finished, :discarded]
      commands = %i[queued running].map do |metric_name|
        value = GoodJob::Job.where(queue_name:).send(metric_name).count
        format(command_template, metric_name:, time_stamp: Time.now.to_i, value:, queue_name:)
      end
      system(commands.join('; '))
    end
  end
end
