namespace :jobs do
  desc 'Send job queue metrics to AWS Cloudwatch'
  task send_job_queue_metrics_to_cloudwatch: :environment do
    command_template = "aws cloudwatch put-metric-data --metric-name %{metric_name} --namespace GoodJob --value=%{value} --unit Count --region='eu-west-2' --dimensions InstanceId=%{instance_id},QueueName=%{queue_name}"

    GoodJob::Job.distinct(:queue_name).pluck(:queue_name).each do |queue_name|
      [:scheduled, :retried, :queued, :running, :finished, :discarded].each do |status|
        count = GoodJob::Job.where(queue_name: queue_name).send(status).count
        instance_id = system('ec2-metadata --instance-id | cut -d " " -f 2')
        command = command_template % { metric_name: status.capitalize, value: count, instance_id: instance_id, queue_name: queue_name }
        system("#{command}")
      end
    end
  end
end
