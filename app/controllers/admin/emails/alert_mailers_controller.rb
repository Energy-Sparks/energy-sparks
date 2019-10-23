module Admin::Emails
  class AlertMailersController < AdminController
    layout 'layouts/alert_mailer'

    def show
      @email = Email.find(params[:id])
      @email_address = @email.contact.email_address
      @school = @email.contact.school
      @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')
      @alert_content = AlertMailer.create_content(@email.alert_subscription_events.by_priority)

      render 'alert_mailer/alert_email'
    end
  end
end
