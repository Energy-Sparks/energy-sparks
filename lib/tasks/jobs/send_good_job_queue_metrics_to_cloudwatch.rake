namespace :jobs do
  desc 'Send good job queue metrics to AWS Cloudwatch'
  task send_good_job_queue_metrics_to_cloudwatch: :environment do
    instance_id = `ec2-metadata --instance-id | cut -d " " -f 2`.strip
    command_template = "aws cloudwatch put-metric-data --metric-name %{metric_name} --timestamp %{time_stamp} --namespace GoodJob --value=%{value} --unit Count --region='eu-west-2' --dimensions InstanceId=#{instance_id},QueueName=%{queue_name}"

    GoodJob::Job.distinct(:queue_name).pluck(:queue_name).each do |queue_name|
      commands = []

      [:queued].each do |status|
        count = GoodJob::Job.where(queue_name: queue_name).send(status).count

        commands << (command_template % {
          metric_name: status.capitalize,
          time_stamp: Time.now.to_i,
          value: count,
          queue_name: queue_name
        })
      end

      commands.each { |command| system(command) }
    end
  end
end
