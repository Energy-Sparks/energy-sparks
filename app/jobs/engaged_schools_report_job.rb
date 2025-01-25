# frozen_string_literal: true

class EngagedSchoolsReportJob < ApplicationJob
  def perform(to, previous_year, school_group_id)
    AdminMailer.with(to:, csv: csv_report(previous_year, school_group_id)).engaged_schools_report.deliver
  end

  def csv_report(previous_year, school_group_id)
    engaged_schools = Schools::EngagedSchoolService.list_schools(previous_year:, school_group_id:)
    CSV.generate(headers: true) do |csv|
      csv << ['School Group', 'School', 'Funder', 'Country', 'Activities', 'Actions',
              'Programmes', 'Target?', 'Transport survey?', 'Temperatures?', 'Audit?',
              'Active users', 'Last visit']
      engaged_schools.each do |service|
        csv << [
          service.school_group.name,
          service.school.name,
          service.school.funder.present? ? service.school.funder.name : nil,
          service.school.country.humanize,
          service.recent_activity_count,
          service.recent_action_count,
          service.recently_enrolled_programme_count,
          service.active_target? ? 'Y' : 'N',
          service.transport_surveys? ? 'Y' : 'N',
          service.temperature_recordings? ? 'Y' : 'N',
          service.audits? ? 'Y' : 'N',
          service.recently_logged_in_user_count,
          service.most_recent_login.present? ? service.most_recent_login.iso8601 : nil
        ]
      end
    end
  end
end
