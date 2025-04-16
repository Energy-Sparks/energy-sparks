# frozen_string_literal: true

class EngagedSchoolsReportJob < ApplicationJob
  def perform(to, previous_year, school_group_id)
    AdminMailer.engaged_schools_report(to,
                                       csv_report(previous_year, school_group_id),
                                       previous_year,
                                       school_group_id).deliver
  end

  private

  def format_bool(bool)
    bool ? 'Y' : 'N'
  end

  def row
    { school_group: ->(service) { service.school_group.name },
      school: ->(service) { service.school.name },
      school_type: ->(service) { service.school.school_type&.humanize },
      funder: ->(service) { service.school.funder&.name },
      country: ->(service) { service.school.country.humanize },
      active: ->(service) { format_bool(service.school.active) },
      data_visible: ->(service) { format_bool(service.school.data_visible?) },
      admin: ->(service) { service.school.default_issues_admin_user&.name },
      activities: ->(service) { service.recent_activity_count },
      actions: ->(service) { service.recent_action_count },
      programmes: ->(service) { service.recently_enrolled_programme_count },
      target?: ->(service) { format_bool(service.active_target?) },
      transport_survey?: ->(service) { format_bool(service.transport_surveys?) },
      temperatures?: ->(service) { format_bool(service.temperature_recordings?) },
      audit?: ->(service) { format_bool(service.audits?) },
      active_users: ->(service) { service.recently_logged_in_user_count },
      last_visit: ->(service) { service.most_recent_login&.iso8601 } }
  end

  def csv_report(previous_year, school_group_id)
    engaged_schools = Schools::EngagedSchoolService.list_schools(previous_year, school_group_id)
    CSV.generate(headers: true) do |csv|
      csv << row.keys.map { |header| header.to_s.titleize }
      engaged_schools.each do |service|
        csv << row.values.map { |lambda| lambda.call(service) }
      end
    end
  end
end
