require 'rollbar_api/rql_jobs'

class RollbarNotifierService
  def initialize(rql_jobs = RollbarAPI::RQLJobs.new, description = nil)
    @rql_jobs = rql_jobs
    @description = description
  end

  REPORTS = {
    validation_errors: {
      title: "Validation, content and related errors",
      description: "Lists problems encountered with validating readings, generating content batches, equivalences, etc",
      rql_query: <<-QUERY
        SELECT timestamp, body.trace.exception.message, body.trace.extra.alert_type, body.trace.extra.school_id, body.trace.extra.school_name
        from item_occurrence
        where request.url is null
        AND body.trace.extra.school_id != NULL
        AND body.trace.extra.alert_type = NULL
        ORDER by timestamp desc
      QUERY
    },
    chart_errors: {
      title: "Chart errors",
      description: "Lists errors reported when generating charts",
      rql_query: <<-QUERY
        SELECT timestamp, request.url, context, request.params.school_id, body.trace.exception.message, body.trace.extra.school_name,
        body.trace.extra.chart_config_overrides.y_axis_units, body.trace.extra.original_chart_type, body.trace.extra.transformations
        from item_occurrence
        WHERE
        body.trace.extra.original_chart_type != NULL
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
