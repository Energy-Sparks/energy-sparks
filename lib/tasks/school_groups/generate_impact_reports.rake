# frozen_string_literal: true

namespace :school_groups do
  task generate_impact_reports: :environment do
    require 'dashboard'
    SchoolGroup.find_each do |school_group|
      next if school_group.assigned_schools.active.empty?

      SchoolGroups::ImpactReport::Generator.new(school_group).create_metrics!
    end
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: 'school_groups:generate_impact_reports')
  end
end
