class AlertMailer < ApplicationMailer
  helper :application

  def alert_email
    @email_address = params[:email_address]
    @events = params[:events]
    @school = params[:school]
    @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')
    @alert_content = self.class.create_content(@events)
    @target_prompt = params[:target_prompt]

    make_bootstrap_mail(to: @email_address, subject: 'Energy Sparks alerts')
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
end
