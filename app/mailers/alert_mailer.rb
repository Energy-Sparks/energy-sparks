class AlertMailer < LocaleMailer
  include MailgunMailerHelper

  helper :application
  helper :schools

  after_action :prevent_delivery_from_test

  def alert_email
    @email_address = params[:email_address]
    @events = params[:events]
    @school = params[:school]
    @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')
    @alert_content = self.class.create_content(@events)
    @target_prompt = params[:target_prompt]
    @title = @school.name

    email = make_bootstrap_mail(to: @email_address)
    add_mg_email_tag(email, 'alerts')
  end

  def self.create_content(events)
    events.map do |event|
      TemplateInterpolation.new(
        event.content_version,
        with_objects: {
          alert: event.alert,
          find_out_more: event.find_out_more,
          unsubscription_uuid: event.unsubscription_uuid
        }
      ).interpolate(
        :email_content, :email_title,
        with: event.alert.template_variables
      )
    end
  end

  def prevent_delivery_from_test
    mail.perform_deliveries = false unless ENV['SEND_AUTOMATED_EMAILS'] == 'true'
  end
end
