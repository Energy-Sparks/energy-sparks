module Admin::Emails
  class AlertMailersController < AdminController
    layout 'layouts/alert_mailer'

    def show
      @email = Email.find(params[:id])
      @email_address = @email.contact.email_address
      @school = @email.contact.school
      @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')

      @alert_content = @email.alert_subscription_events.map do |event|
        TemplateInterpolation.new(
          event.content_version,
          with_objects: { alert: event.alert },
        ).interpolate(
          :email_content, :email_title,
          with: event.alert.template_variables
        )
      end

      render 'alert_mailer/alert_email'
    end
  end
end
