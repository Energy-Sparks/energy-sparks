class AlertMailerPreview < ActionMailer::Preview
  def alert_email
    @unsubscribe_emails = User.where(school_id: params[:school_id], role: :school_admin).pluck(:email).join(', ')

    email = Email.find(params[:email_id])
    alerts = email.alerts
    school = School.find(params[:school_id])

    AlertMailer.with(email_address: params[:email_address], alerts: alerts, school: school).alert_email
  end

  def self.custom_url(school_id, email_address, email_id)
    "/rails/mailers/alert_mailer/alert_email?school_id=#{school_id}&email_address=#{email_address}&email_id=#{email_id}"
  end
end
