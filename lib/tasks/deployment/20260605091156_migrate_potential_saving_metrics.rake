# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: migrate_potential_saving_metrics'
  task migrate_potential_saving_metrics: :environment do
    puts "Running deploy task 'migrate_potential_saving_metrics'"
    require 'dashboard'
    %i[heating_down heating_early heating_off insulate_pipes peak solar_panels thermostatic_control
       use].each do |metric_type|
      ImpactReport::Metric.where(metric_type: "#{metric_type}_gbp").update_all(metric_type:) # rubocop:disable Rails/SkipsModelValidations
      ImpactReport::Metric.where(metric_type: "#{metric_type}_co2").delete_all
      ImpactReport::Metric.where(metric_type: "#{metric_type}_kwh").delete_all
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
