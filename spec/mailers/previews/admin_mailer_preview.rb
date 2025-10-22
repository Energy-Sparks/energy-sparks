# frozen_string_literal: true

class AdminMailerPreview < ActionMailer::Preview
  def issues_report
    AdminMailer.with(email_address: 'test@blah.com', user: User.admin.first).issues_report
  end

  def stopped_data_feeds
    missing = [[AmrDataFeedConfig.order(:missing_reading_window).first, 10.days]]
    AdminMailer.with(to: 'operations@energysparks.uk', missing:).stopped_data_feeds
  end

  def self.school_group_meter_data_export_params
    { school_group_id: SchoolGroup.all.sample&.id }
  end

  def school_group_meter_data_export
    AdminMailer.school_group_meter_data_export(SchoolGroup.find(params[:school_group_id]), 'test@example.com')
  end
end
