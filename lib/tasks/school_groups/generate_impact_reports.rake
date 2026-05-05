# frozen_string_literal: true

namespace :school_groups do
  task generate_impact_reports: :environment do
    SchoolGroup.find_each do |school_group|
      next if school_group.assigned_schools.active.empty?

      report = SchoolGroups::ImpactReport.new(school_group)
      run = ImpactReport::Run.create!(school_group:, run_date: Date.current)
      %i[overview engagement potential_savings].each do |metric_category|
        ImpactReport::Metric.metrics(metric_category).each do |metric_type|
          value = report.value(metric_category, metric_type)
          next if value.nil?

          run.metrics.create!(enough_data: true, metric_category:, metric_type:,
                              number_of_schools: report.number_of_schools(metric_category, metric_type),
                              value:)
        end
      end
    end
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: 'school_groups:generate_impact_reports')
  end
end
