# frozen_string_literal: true

class AlertMailer < LocaleMailer
  include MailgunMailerHelper

  helper :application
  helper :schools
  helper AdvicePageHelper

  after_action :prevent_delivery_from_test

  def alert_email
    @batch_email = params[:users].present?

    @email_addresses = @batch_email ? params[:users].map(&:email_address) : params[:email_address]

    @events = params[:events]
    @school = params[:school]
    @target_prompt = params[:target_prompt]

    unless Flipper.enabled?(:profile_pages)
      @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')
    end
    @alert_content = self.class.create_content(@events)
    @title = @school.name

    subject = I18n.with_locale(locale_param) do
      I18n.t('alert_mailer.alert_email.subject_2024', school_name: @school.name)
    end
    email = make_bootstrap_mail(to: @email_addresses, subject:)
    email.mailgun_options = { deliverytime: deliverytime }
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
        },
        proxy: [:colour]
      ).interpolate(
        :email_content, :email_title,
        with: event.alert.template_variables
      )
    end
  end

  def deliverytime
    (Time.zone.now + 15.minutes).rfc822
  end
end
