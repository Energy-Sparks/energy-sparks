class AdminMailerPreview < ActionMailer::Preview
  def issues_report
    AdminMailer.with(email_address: 'test@blah.com', user: User.admin.last).issues_report
  end
end
