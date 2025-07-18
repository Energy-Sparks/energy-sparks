require 'csv'

module Admin
  module Reports
    class GoodJobsController < AdminController
      def index
        @queue_and_job_class_statistics = build_queue_and_job_class_statistics
        @slowest_jobs = find_slowest_jobs_per_queue_and_job_class
      end

      def export
        @jobs = find_jobs_per_queue_and_job_class
        respond_to do |format|
          format.csv do
            response.headers['Content-Type'] = 'text/csv'
            response.headers['Content-Disposition'] = 'attachment; filename=good_jobs_time_to_completion.csv'
          end
        end
      end

      private

      def find_jobs_per_queue_and_job_class
        query = <<-SQL.squish
          select
          queue_name,
          serialized_params->>'job_class' as job_class,
          serialized_params->>'job_id' as job_id,
          serialized_params->>'arguments' as school_id,
          performed_at,
          finished_at,
          date_trunc('day', performed_at) as run_date,
          extract(EPOCH from (finished_at - performed_at)) as time_to_completion_in_seconds
          from good_jobs
        SQL

        ActiveRecord::Base.connection.execute(query)
      end

      def find_slowest_jobs_per_queue_and_job_class
        query = <<-SQL.squish
          select * from (
            select
            row_number() over (partition BY queue_name, serialized_params->>'job_class' ORDER BY (finished_at - performed_at) desc) AS row,
            queue_name,
            serialized_params->>'job_class' as job_class,
            serialized_params->>'job_id' as job_id,
            (finished_at - performed_at) as time_to_completion
            from good_jobs
            where performed_at > (current_date - interval '2 days')
            group by queue_name, serialized_params->>'job_class', serialized_params->>'job_id', (finished_at - performed_at)
            order by (finished_at - performed_at) desc
          ) jobs
          where jobs.row <= 5
        SQL

        ActiveRecord::Base.connection.execute(query)
      end

      def build_queue_and_job_class_statistics
        query = <<-SQL.squish
          select
          date_trunc('day', created_at) as date,
          queue_name,
          serialized_params->>'job_class' as job_class,
          count(*),
          AVG(finished_at - performed_at) as average,
          MIN(finished_at - performed_at) as minimum,
          MAX(finished_at - performed_at) as maximum,
          MAX(finished_at) as finished
          from good_jobs
          where created_at >= NOW() - INTERVAL '14 days'
          group by date_trunc('day', created_at), queue_name, serialized_params->>'job_class'
          order by date_trunc('day', created_at) desc
        SQL

        ActiveRecord::Base.connection.execute(query)
      end
    end
  end
end
