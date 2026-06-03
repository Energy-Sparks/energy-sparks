# frozen_string_literal: true

class AdminMailerPreview < ActionMailer::Preview
  def school_data_source_report
    data_source_id = DataSource.where(name: 'Ecotricity').first.id
    # Used Ecotricity as example because it has inactive and active meters, plus archived and non-archived schools
    AdminMailer.with(to: 'operations@energysparks.uk', data_source_id:).school_data_source_report
  end

  def issues_report
    IssuesReportMailer.with(user: User.admin.first).issues_report
  end

  def stopped_data_feeds
    missing = [[AmrDataFeedConfig.order(:missing_reading_window).first, 10.days]]
    AdminMailer.with(to: 'operations@energysparks.uk', missing:).stopped_data_feeds
  end

  def lagging_data_sources
    lagging = [DataSource.all.find_each.filter(&:exceeded_alert_threshold?).first]
    AdminMailer.with(to: 'operations@energysparks.uk', lagging:).lagging_data_sources
  end

  def self.school_group_meter_data_export_params
    { school_group_id: SchoolGroup.organisation_groups.sample&.id }
  end

  def school_group_meter_data_export
    AdminMailer.school_group_meter_data_export(SchoolGroup.find(params[:school_group_id]), 'test@example.com')
  end

  def regeneration_errors
    AdminMailer.regeneration_errors((0..5).map do
      RegenerationError.new(school: School.active.sample, raised_at: Time.current,
                            message: 'Invalid AMR date range. Minimum date (2026-02-19) after maximum date ' \
                                     '(2025-10-01) unable to aggregate data')
    end)
  end
end
