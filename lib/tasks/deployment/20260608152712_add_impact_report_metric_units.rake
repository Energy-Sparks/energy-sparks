# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_impact_report_metric_units'
  task add_impact_report_metric_units: :environment do
    puts "Running deploy task 'add_impact_report_metric_units'"
    require 'dashboard'

    %w[holiday_previous_gbp holiday_previous_kwh
       holiday_previous_year_gbp holiday_previous_year_kwh
       annual_saving_gbp annual_saving_co2 annual_saving_kwh].each do |metric_type|
      new_metric_type, _, unit = metric_type.rpartition('_')
      ImpactReport::Metric.where(metric_type:).update_all(metric_type: new_metric_type, unit:) # rubocop:disable Rails
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
