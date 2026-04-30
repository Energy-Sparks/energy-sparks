# frozen_string_literal: true

namespace :school_groups do
  task generate_impact_reports: :environment do
    SchoolGroup.find_each do |school_group|
      next if school_group.assigned_schools.active.empty?

      report = SchoolGroups::ImpactReport.new(school_group)
      run = ImpactReport::Run.create!(school_group:, run_date: Date.current)
      ImpactReport::Metric::OVERVIEW_METRICS.each do |metric_type|
        value = report.overview.public_send(metric_type)
        run.metrics.create!(enough_data: true, number_of_schools: report.overview.visible_schools,
                            metric_category: :overview, metric_type:, value:)
      end
    end
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: 'school_groups:generate_impact_reports')
  end
end
