module Admin
  module Reports
    class GoodJobsController < AdminController
      def index
        @queue_and_job_class_statistics = build_queue_and_job_class_statistics
      end

      private

      def build_queue_and_job_class_statistics
        query = <<-SQL.squish
          select
          date_trunc('day', created_at) as date,
          queue_name,
          serialized_params->>'job_class' as job_class,
          AVG(finished_at - performed_at),
          MIN(finished_at - performed_at),
          MAX(finished_at - performed_at)
          from good_jobs
          where created_at >= NOW() - INTERVAL '7 days'
          group by date_trunc('day', created_at), queue_name, serialized_params->>'job_class'
        SQL

        ActiveRecord::Base.connection.execute(query)
      end
    end
  end
end
