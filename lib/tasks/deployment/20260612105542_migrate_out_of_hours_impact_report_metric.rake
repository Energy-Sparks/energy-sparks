# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: migrate_out_of_hours_impact_report_metric'
  task migrate_out_of_hours_impact_report_metric: :environment do
    puts "Running deploy task 'migrate_out_of_hours_impact_report_metric'"

    require 'dashboard'

    %w[out_of_hours_gbp out_of_hours_co2 out_of_hours_kwh].each do |metric_type|
      new_metric_type, _, unit = metric_type.rpartition('_')
      ImpactReport::Metric.where(metric_type:).update_all(metric_type: new_metric_type, unit:) # rubocop:disable Rails/SkipsModelValidations
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
