class AdminMailerPreview < ActionMailer::Preview
  def issues_report
    AdminMailer.with(email_address: 'test@blah.com', user: User.admin.last).issues_report
  end

  def stopped_data_feeds
    missing = [[AmrDataFeedConfig.order(:missing_reading_window).first, 10.days]]
    AdminMailer.with(to: 'operations@energysparks.uk', missing:).stopped_data_feeds
  end
end
