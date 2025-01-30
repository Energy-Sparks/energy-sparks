class AdminMailerPreview < ActionMailer::Preview
  def issues_report
    AdminMailer.with(email_address: 'test@blah.com', user: User.admin.last).issues_report
  end

  def missing_reading_window
    missing = [[AmrDataFeedConfig.where.not(missing_reading_window: nil).first, 10.days]]
    AdminMailer.with(to: 'operations@energysparks.uk', missing:).missing_reading_window
  end
end
