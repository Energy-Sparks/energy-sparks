# frozen_string_literal: true

namespace :school_groups do
  task generate_impact_reports: :environment do
    SchoolGroup.find_each do |school_group|
      schools = school_group.assigned_schools.active
      next if schools.empty?

      impact_report_run = ImpactReport::Run.create!(school_group:, run_date: Date.current)
      report = SchoolGroups::ImpactReport.new(school_group)
      ImpactReport::Metric::OVERVIEW_METRICS.each do |metric_type|
        value = report.overview.public_send(metric_type)
        value = value.count if value.respond_to?(:count)
        ImpactReport::Metric.create!(impact_report_run:, enough_data: true, metric_category: :overview, metric_type:,
                                     value:)
      end
    end
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: 'school_groups:generate_impact_reports')
  end
end
