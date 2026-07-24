# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: make_impact_reports_visible'
  task make_impact_reports_visible: :environment do
    puts "Running deploy task 'set_impact_report_visible_for_organisation_groups'"

    SchoolGroup.organisation_groups.with_active_schools.find_each do |school_group|
      ImpactReport::Configuration.find_or_initialize_by(school_group: school_group).update!(visible: true)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
