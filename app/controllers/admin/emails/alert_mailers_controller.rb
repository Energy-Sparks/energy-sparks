module Admin::Emails
  class AlertMailersController < AdminController
    layout 'layouts/alert_mailer'

    def show
      @email = Email.find(params[:id])
      @email_address = @email.contact.email_address
      @alerts = @email.alerts
      @school = @email.contact.school
      @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')

      render 'alert_mailer/alert_email'
    end
  end
end
