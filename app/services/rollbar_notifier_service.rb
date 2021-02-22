require 'rollbar_api/rql_jobs'

class RollbarNotifierService
  def initialize(rql_jobs = RollbarAPI::RQLJobs.new, description = nil)
    @rql_jobs = rql_jobs
    @description = description
  end

  REPORTS = {
    validation_errors: {
      title: "Meter validation problems",
      description: "Meter validation failed for the following schools on the specified day",
      rql_query: <<-QUERY
      SELECT timestamp, body.trace.extra.school_id, body.trace.extra.school_name, body.trace.extra.alert_type, body.trace.exception.message
      from item_occurrence
      where request.url is null
      AND body.trace.extra.school_id != NULL
      AND body.trace.extra.alert_type != NULL
      ORDER by timestamp desc
      QUERY
    }
  }.freeze

  def run_queries
    results = {}
    REPORTS.each do |key, config|
      results[key] = config.dup
      results[key][:results] = run_report(config)
    end
    return results
  end

  def perform
    RollbarMailer.with(reported_results: run_queries, description: @description).report_errors.deliver_now
  end

  private

  def run_report(report)
    query_result = @rql_jobs.run_query(report[:rql_query])
    return {
      columns: query_result["result"]["result"]["columns"],
      rows: query_result["result"]["result"]["rows"]
    }
  rescue => e
    Rails.logger.error "Exception: running RQL report '#{report[:title]}' against rollbar. #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    Rollbar.error(e)
    return { error: true, rows: [], columns: [] }
  end
end
